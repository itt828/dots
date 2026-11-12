package backend

import (
	"context"
	"errors"
	"strconv"
)

func (b *Backend) niri(ctx context.Context, args []string) error {
	if len(args) == 1 {
		switch args[0] {
		case "event-stream", "workspaces", "windows", "focused-window", "focused-output":
			return b.run(ctx, nil, "niri", "msg", "-j", args[0])
		case "power-on-monitors", "screenshot":
			return b.run(ctx, nil, "niri", "msg", "action", args[0])
		}
	}
	if len(args) == 3 && args[0] == "focus" {
		index, err := strconv.Atoi(args[2])
		if err != nil || index < 1 {
			return errors.New("invalid workspace index")
		}
		if err := b.run(ctx, nil, "niri", "msg", "action", "focus-monitor", args[1]); err != nil {
			return err
		}
		return b.run(ctx, nil, "niri", "msg", "action", "focus-workspace", args[2])
	}
	if len(args) == 3 && args[0] == "output" && (args[2] == "on" || args[2] == "off") {
		return b.run(ctx, nil, "niri", "msg", "output", args[1], args[2])
	}
	return errors.New("invalid niri arguments")
}
