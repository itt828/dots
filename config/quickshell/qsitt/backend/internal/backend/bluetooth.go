package backend

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/godbus/dbus/v5"
)

const (
	bluezName                            = "org.bluez"
	bluezAgentManager                    = "org.bluez.AgentManager1"
	bluezAgentInterface                  = "org.bluez.Agent1"
	bluezDeviceInterface                 = "org.bluez.Device1"
	bluetoothAgentPath   dbus.ObjectPath = "/org/qsitt/BluetoothAgent"
)

var (
	bluetoothDevicePath = regexp.MustCompile(`^/org/bluez/hci[0-9]+/dev_(?:[0-9A-F]{2}_){5}[0-9A-F]{2}$`)
	bluetoothPasskey    = regexp.MustCompile(`^[0-9]{1,6}$`)
)

type bluetoothPairingEvent struct {
	Kind    string  `json:"kind"`
	Code    string  `json:"code,omitempty"`
	Entered *uint16 `json:"entered,omitempty"`
}

type bluetoothPairingCommand struct {
	Answer json.RawMessage `json:"answer"`
	Cancel bool            `json:"cancel"`
}

type bluetoothAgentRequest struct {
	event bluetoothPairingEvent
	reply chan json.RawMessage
}

// BlueZ calls the exported methods concurrently. Only the pairing loop owns
// the pending prompt and writes JSON to the frontend.
type bluetoothAgent struct {
	ctx      context.Context
	owner    dbus.Sender
	device   dbus.ObjectPath
	requests chan bluetoothAgentRequest
}

func (b *Backend) bluetooth(ctx context.Context, args []string) error {
	if len(args) != 2 || args[0] != "pair" || !bluetoothDevicePath.MatchString(args[1]) {
		return errors.New("usage: qsittd bluetooth pair <BlueZ device path>")
	}

	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return bluetoothAgentUnavailable(err)
	}
	defer conn.Close()

	devicePath := dbus.ObjectPath(args[1])
	pairCtx, stopPairing := context.WithTimeout(ctx, 90*time.Second)
	defer stopPairing()
	setupCtx, stopSetup := context.WithTimeout(pairCtx, 5*time.Second)
	defer stopSetup()

	var owner string
	if err := conn.BusObject().CallWithContext(setupCtx, "org.freedesktop.DBus.GetNameOwner", 0, bluezName).Store(&owner); err != nil {
		return bluetoothAgentUnavailable(err)
	}
	agent := &bluetoothAgent{ctx: pairCtx, owner: dbus.Sender(owner), device: devicePath, requests: make(chan bluetoothAgentRequest)}
	if err := conn.Export(agent, bluetoothAgentPath, bluezAgentInterface); err != nil {
		return fmt.Errorf("export Bluetooth agent: %w", err)
	}

	manager := conn.Object(owner, "/org/bluez")
	if err := manager.CallWithContext(setupCtx, bluezAgentManager+".RegisterAgent", 0, bluetoothAgentPath, "KeyboardDisplay").Err; err != nil {
		return bluetoothAgentUnavailable(err)
	}
	stopSetup()
	defer func() {
		cleanupCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		_ = manager.CallWithContext(cleanupCtx, bluezAgentManager+".UnregisterAgent", 0, bluetoothAgentPath).Err
	}()

	device := conn.Object(owner, devicePath)
	result := device.GoWithContext(pairCtx, bluezDeviceInterface+".Pair", 0, make(chan *dbus.Call, 1)).Done
	finished, err := b.waitForBluetoothPairing(pairCtx, agent.requests, result)
	stopPairing()
	if !finished {
		cancelCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		_ = device.CallWithContext(cancelCtx, bluezDeviceInterface+".CancelPairing", 0).Err
	}
	return err
}

func bluetoothAgentUnavailable(err error) error {
	return &ExitError{Code: 20, Message: fmt.Sprintf("Bluetooth pairing agent is unavailable: %v", err)}
}

func (b *Backend) waitForBluetoothPairing(ctx context.Context, requests <-chan bluetoothAgentRequest, result <-chan *dbus.Call) (bool, error) {
	in := b.In
	if in == nil {
		in = os.Stdin
	}
	commands := make(chan bluetoothPairingCommand)
	go readBluetoothPairingCommands(ctx, in, commands)

	var pending chan json.RawMessage
	for {
		select {
		case <-ctx.Done():
			return false, b.json(bluetoothPairingEvent{Kind: "cancelled"})
		case call := <-result:
			if ctx.Err() != nil {
				return false, b.json(bluetoothPairingEvent{Kind: "cancelled"})
			}
			if call.Err != nil {
				_ = b.json(bluetoothPairingEvent{Kind: "error"})
				return true, fmt.Errorf("pair Bluetooth device: %w", call.Err)
			}
			return true, b.json(bluetoothPairingEvent{Kind: "success"})
		case request := <-requests:
			if pending != nil {
				pending <- nil
			}
			pending = request.reply
			if request.event.Kind == "released" {
				_ = b.json(bluetoothPairingEvent{Kind: "error"})
				return false, errors.New("BlueZ released the pairing agent")
			}
			if err := b.json(request.event); err != nil {
				return false, err
			}
		case command, ok := <-commands:
			if !ok || command.Cancel {
				return false, b.json(bluetoothPairingEvent{Kind: "cancelled"})
			}
			if pending != nil && len(command.Answer) != 0 {
				pending <- command.Answer
				pending = nil
			}
		}
	}
}

func readBluetoothPairingCommands(ctx context.Context, input io.Reader, commands chan<- bluetoothPairingCommand) {
	defer close(commands)
	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		var command bluetoothPairingCommand
		if json.Unmarshal(scanner.Bytes(), &command) != nil {
			continue
		}
		select {
		case commands <- command:
		case <-ctx.Done():
			return
		}
	}
}

func (a *bluetoothAgent) deliver(sender dbus.Sender, device dbus.ObjectPath, request bluetoothAgentRequest) *dbus.Error {
	if sender != a.owner || device != a.device {
		return dbus.NewError("org.bluez.Error.Rejected", []any{"Unexpected sender or device"})
	}
	select {
	case a.requests <- request:
		return nil
	case <-a.ctx.Done():
		return bluetoothPromptCancelled()
	}
}

func (a *bluetoothAgent) ask(sender dbus.Sender, device dbus.ObjectPath, event bluetoothPairingEvent, answer any) *dbus.Error {
	reply := make(chan json.RawMessage, 1)
	if err := a.deliver(sender, device, bluetoothAgentRequest{event: event, reply: reply}); err != nil {
		return err
	}
	select {
	case value := <-reply:
		if value == nil {
			return bluetoothPromptCancelled()
		}
		if json.Unmarshal(value, answer) != nil {
			return bluetoothPromptRejected()
		}
		return nil
	case <-a.ctx.Done():
		return bluetoothPromptCancelled()
	}
}

func bluetoothPromptCancelled() *dbus.Error {
	return dbus.NewError("org.bluez.Error.Canceled", []any{"Pairing prompt closed"})
}

func bluetoothPromptRejected() *dbus.Error {
	return dbus.NewError("org.bluez.Error.Rejected", []any{"Pairing was declined"})
}

func (a *bluetoothAgent) RequestPinCode(sender dbus.Sender, device dbus.ObjectPath) (string, *dbus.Error) {
	var pin string
	if err := a.ask(sender, device, bluetoothPairingEvent{Kind: "pin"}, &pin); err != nil {
		return "", err
	}
	if length := utf8.RuneCountInString(pin); length < 1 || length > 16 || strings.ContainsRune(pin, 0) {
		return "", bluetoothPromptRejected()
	}
	return pin, nil
}

func (a *bluetoothAgent) RequestPasskey(sender dbus.Sender, device dbus.ObjectPath) (uint32, *dbus.Error) {
	var input string
	if err := a.ask(sender, device, bluetoothPairingEvent{Kind: "passkey"}, &input); err != nil {
		return 0, err
	}
	if !bluetoothPasskey.MatchString(input) {
		return 0, bluetoothPromptRejected()
	}
	passkey, _ := strconv.ParseUint(input, 10, 32)
	return uint32(passkey), nil
}

func (a *bluetoothAgent) confirm(sender dbus.Sender, device dbus.ObjectPath, event bluetoothPairingEvent) *dbus.Error {
	var accepted bool
	if err := a.ask(sender, device, event, &accepted); err != nil {
		return err
	}
	if !accepted {
		return bluetoothPromptRejected()
	}
	return nil
}

func (a *bluetoothAgent) RequestConfirmation(sender dbus.Sender, device dbus.ObjectPath, passkey uint32) *dbus.Error {
	return a.confirm(sender, device, bluetoothPairingEvent{Kind: "confirm", Code: fmt.Sprintf("%06d", passkey)})
}

func (a *bluetoothAgent) RequestAuthorization(sender dbus.Sender, device dbus.ObjectPath) *dbus.Error {
	return a.confirm(sender, device, bluetoothPairingEvent{Kind: "authorize"})
}

func (a *bluetoothAgent) DisplayPinCode(sender dbus.Sender, device dbus.ObjectPath, pin string) *dbus.Error {
	return a.deliver(sender, device, bluetoothAgentRequest{event: bluetoothPairingEvent{Kind: "display", Code: pin}})
}

func (a *bluetoothAgent) DisplayPasskey(sender dbus.Sender, device dbus.ObjectPath, passkey uint32, entered uint16) *dbus.Error {
	return a.deliver(sender, device, bluetoothAgentRequest{event: bluetoothPairingEvent{
		Kind: "display", Code: fmt.Sprintf("%06d", passkey), Entered: &entered,
	}})
}

func (a *bluetoothAgent) AuthorizeService(device dbus.ObjectPath, uuid string) *dbus.Error {
	return dbus.NewError("org.bluez.Error.Rejected", []any{"Service authorization is outside this pairing session"})
}

func (a *bluetoothAgent) Cancel(sender dbus.Sender) *dbus.Error {
	// BlueZ also dismisses a displayed passkey via Cancel when pairing succeeds.
	return a.deliver(sender, a.device, bluetoothAgentRequest{event: bluetoothPairingEvent{Kind: "waiting"}})
}

func (a *bluetoothAgent) Release(sender dbus.Sender) *dbus.Error {
	return a.deliver(sender, a.device, bluetoothAgentRequest{event: bluetoothPairingEvent{Kind: "released"}})
}
