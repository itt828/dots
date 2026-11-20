package search

import "testing"

func TestCalculate(t *testing.T) {
	for _, test := range []struct {
		input string
		want  string
	}{
		{"(128 + 32) / 2", "80"},
		{"2 + 3 * -4", "-10"},
		{"-.5 + .5", "0"},
		{"1e-3 * 200", "0.2"},
		{"4 / (3 - 3)", ""},
		{"1e308 * 2", ""},
		{"3 << 1", ""},
		{"(2 + 3", ""},
		{"float64(40)", ""},
		{"1 /* */ + 2", ""},
	} {
		got, ok := calculate(test.input)
		if got != test.want || ok != (test.want != "") {
			t.Errorf("calculate(%q) = (%q, %t), want %q", test.input, got, ok, test.want)
		}
	}
}
