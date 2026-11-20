package search

import (
	"go/ast"
	"go/parser"
	"go/token"
	"math"
	"strconv"
	"strings"
)

// calculate accepts arithmetic expressions only. In particular it does not
// evaluate identifiers, calls, or other Go expressions.
func calculate(input string) (string, bool) {
	if input == "" || len(input) > 256 {
		return "", false
	}
	for _, r := range input {
		if !strings.ContainsRune("0123456789.eE+-*/() \t\n\r", r) {
			return "", false
		}
	}
	if strings.Contains(input, "/*") || strings.Contains(input, "//") {
		return "", false
	}
	expression, err := parser.ParseExpr(input)
	if err != nil {
		return "", false
	}
	value := arithmetic(expression)
	if math.IsNaN(value) || math.IsInf(value, 0) {
		return "", false
	}
	if value == 0 {
		value = 0 // Normalize negative zero before displaying or copying it.
	}
	return strconv.FormatFloat(value, 'g', 12, 64), true
}

func arithmetic(expression ast.Expr) float64 {
	switch expr := expression.(type) {
	case *ast.BasicLit:
		if expr.Kind == token.INT || expr.Kind == token.FLOAT {
			value, err := strconv.ParseFloat(expr.Value, 64)
			if err == nil {
				return value
			}
		}
	case *ast.ParenExpr:
		return arithmetic(expr.X)
	case *ast.UnaryExpr:
		switch expr.Op {
		case token.ADD:
			return arithmetic(expr.X)
		case token.SUB:
			return -arithmetic(expr.X)
		}
	case *ast.BinaryExpr:
		left, right := arithmetic(expr.X), arithmetic(expr.Y)
		switch expr.Op {
		case token.ADD:
			return left + right
		case token.SUB:
			return left - right
		case token.MUL:
			return left * right
		case token.QUO:
			if right != 0 {
				return left / right
			}
		}
	}
	return math.NaN()
}
