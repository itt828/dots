package backend

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/godbus/dbus/v5"
)

const pairingTestDevice dbus.ObjectPath = "/org/bluez/hci0/dev_00_11_22_33_44_55"

type fakeBlueZ struct {
	conn         *dbus.Conn
	pair         func(dbus.BusObject) error
	registered   chan dbus.Sender
	unregistered chan dbus.Sender
	cancelled    chan struct{}
}

func (f *fakeBlueZ) RegisterAgent(sender dbus.Sender, path dbus.ObjectPath, capability string) *dbus.Error {
	if path != bluetoothAgentPath || capability != "KeyboardDisplay" {
		return dbus.MakeFailedError(fmt.Errorf("unexpected agent: %s %s", path, capability))
	}
	f.registered <- sender
	return nil
}

func (f *fakeBlueZ) UnregisterAgent(sender dbus.Sender, path dbus.ObjectPath) *dbus.Error {
	if path != bluetoothAgentPath {
		return dbus.MakeFailedError(fmt.Errorf("unexpected agent path: %s", path))
	}
	f.unregistered <- sender
	return nil
}

func (f *fakeBlueZ) Pair(sender dbus.Sender) *dbus.Error {
	select {
	case registered := <-f.registered:
		if sender != registered {
			return dbus.MakeFailedError(fmt.Errorf("Pair called from %s, registered %s", sender, registered))
		}
	default:
		return dbus.MakeFailedError(fmt.Errorf("no pairing agent registered"))
	}
	if err := f.pair(f.conn.Object(string(sender), bluetoothAgentPath)); err != nil {
		return dbus.MakeFailedError(err)
	}
	return nil
}

func (f *fakeBlueZ) CancelPairing() *dbus.Error {
	f.cancelled <- struct{}{}
	return nil
}

func TestBluetoothPairingOverDBus(t *testing.T) {
	binary, err := exec.LookPath("dbus-daemon")
	if err != nil {
		t.Skip("dbus-daemon is required for the isolated BlueZ test")
	}
	daemon := exec.CommandContext(t.Context(), binary, "--session", "--nofork", "--print-address=1", "--address=unix:tmpdir="+t.TempDir())
	output, err := daemon.StdoutPipe()
	if err != nil {
		t.Fatal(err)
	}
	if err := daemon.Start(); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_ = daemon.Process.Kill()
		_ = daemon.Wait()
	})
	address, err := bufio.NewReader(output).ReadString('\n')
	if err != nil {
		t.Fatalf("start private D-Bus: %v", err)
	}
	t.Setenv("DBUS_SYSTEM_BUS_ADDRESS", strings.TrimSpace(address))
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	if reply, err := conn.RequestName(bluezName, dbus.NameFlagDoNotQueue); err != nil || reply != dbus.RequestNameReplyPrimaryOwner {
		t.Fatalf("own BlueZ name on private bus: %v, %v", reply, err)
	}

	for _, test := range []struct {
		name string
		pair func(context.Context, dbus.BusObject) error
		ui   func(read func(string, string), write func(string))
	}{
		{
			name: "PIN, passkey, confirmation and display dismissal",
			pair: func(ctx context.Context, agent dbus.BusObject) error {
				var pin string
				if err := agent.CallWithContext(ctx, bluezAgentInterface+".RequestPinCode", 0, pairingTestDevice).Store(&pin); err != nil || pin != "0420" {
					return fmt.Errorf("PIN: %q, %v", pin, err)
				}
				var passkey uint32
				if err := agent.CallWithContext(ctx, bluezAgentInterface+".RequestPasskey", 0, pairingTestDevice).Store(&passkey); err != nil || passkey != 12 {
					return fmt.Errorf("passkey: %d, %v", passkey, err)
				}
				if err := agent.CallWithContext(ctx, bluezAgentInterface+".RequestConfirmation", 0, pairingTestDevice, uint32(42)).Err; err != nil {
					return err
				}
				if err := agent.CallWithContext(ctx, bluezAgentInterface+".RequestAuthorization", 0, pairingTestDevice).Err; err != nil {
					return err
				}
				if err := agent.CallWithContext(ctx, bluezAgentInterface+".DisplayPasskey", 0, pairingTestDevice, uint32(42), uint16(0)).Err; err != nil {
					return err
				}
				return agent.CallWithContext(ctx, bluezAgentInterface+".Cancel", 0).Err
			},
			ui: func(read func(string, string), write func(string)) {
				read("pin", "")
				write(`{"answer":"0420"}`)
				read("passkey", "")
				write(`{"answer":"000012"}`)
				read("confirm", "000042")
				write(`{"answer":true}`)
				read("authorize", "")
				write(`{"answer":true}`)
				read("display", "000042")
				read("waiting", "")
				read("success", "")
			},
		},
		{
			name: "cancel with an outstanding prompt",
			pair: func(ctx context.Context, agent dbus.BusObject) error {
				return agent.CallWithContext(ctx, bluezAgentInterface+".RequestConfirmation", 0, pairingTestDevice, uint32(99)).Err
			},
			ui: func(read func(string, string), write func(string)) {
				read("confirm", "000099")
				write(`{"cancel":true}`)
				read("cancelled", "")
			},
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
			defer cancel()
			fake := &fakeBlueZ{
				conn: conn, pair: func(agent dbus.BusObject) error { return test.pair(ctx, agent) },
				registered: make(chan dbus.Sender, 1), unregistered: make(chan dbus.Sender, 1), cancelled: make(chan struct{}, 1),
			}
			if err := conn.Export(fake, "/org/bluez", bluezAgentManager); err != nil {
				t.Fatal(err)
			}
			if err := conn.Export(fake, pairingTestDevice, bluezDeviceInterface); err != nil {
				t.Fatal(err)
			}

			backendInput, input := io.Pipe()
			defer backendInput.Close()
			defer input.Close()
			output, backendOutput := io.Pipe()
			defer output.Close()
			result := make(chan error, 1)
			go func() {
				b := Backend{In: backendInput, Out: backendOutput}
				err := b.Run(ctx, []string{"bluetooth", "pair", string(pairingTestDevice)})
				_ = backendOutput.Close()
				result <- err
			}()

			var lastEvent string
			scanner := bufio.NewScanner(output)
			test.ui(func(kind, code string) {
				t.Helper()
				if !scanner.Scan() {
					t.Fatalf("waiting for %q: %v", kind, scanner.Err())
				}
				var event bluetoothPairingEvent
				if err := json.Unmarshal(scanner.Bytes(), &event); err != nil || event.Kind != kind || event.Code != code {
					t.Fatalf("expected %q %q, got %s (%v)", kind, code, scanner.Bytes(), err)
				}
				lastEvent = kind
			}, func(line string) {
				t.Helper()
				if _, err := fmt.Fprintln(input, line); err != nil {
					t.Fatal(err)
				}
			})
			if err := <-result; err != nil {
				t.Fatal(err)
			}
			if len(fake.unregistered) != 1 || (len(fake.cancelled) == 1) != (lastEvent == "cancelled") {
				t.Fatal("unexpected agent cleanup")
			}
		})
	}

	if _, err := conn.ReleaseName(bluezName); err != nil {
		t.Fatal(err)
	}
	b := Backend{Out: io.Discard}
	err = b.Run(t.Context(), []string{"bluetooth", "pair", string(pairingTestDevice)})
	if err == nil || ExitCode(err) != 20 {
		t.Fatalf("expected fallback exit code, got %v", err)
	}
}
