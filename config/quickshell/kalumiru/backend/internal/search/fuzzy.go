package search

import (
	"math"
	"strings"
	"unicode"

	"golang.org/x/text/cases"
)

func fold(value string) string { return cases.Fold().String(value) }

// FuzzyScore ranks ordered-character matches. Lower scores are better.
func FuzzyScore(text, query string) (float64, bool) {
	words := strings.Fields(fold(query))
	if len(words) == 0 {
		return 0, true
	}
	value := []rune(fold(text))
	original := []rune(text)
	lengthPenalty := float64(min(len(value), 200)) * .1
	boundary := func(i int) bool {
		return i == 0 || (!unicode.IsLetter(value[i-1]) && !unicode.IsNumber(value[i-1])) ||
			(i < len(original) && unicode.IsUpper(original[i]) && unicode.IsLower(original[i-1]))
	}
	total := 0.0
	for _, word := range words {
		if word == string(value) {
			total -= 1000
			continue
		}
		if strings.HasPrefix(string(value), word) {
			total -= 500 - lengthPenalty
			continue
		}
		if index := strings.Index(string(value), word); index >= 0 {
			position := len([]rune(string(value)[:index]))
			total -= 200 - float64(position)*2 - lengthPenalty
			continue
		}
		chars := []rune(word)
		previous := make([]float64, len(value))
		for i, char := range value {
			previous[i] = math.Inf(1)
			if char == chars[0] {
				previous[i] = float64(i) * 1.5
				if boundary(i) {
					previous[i] -= 6
				}
			}
		}
		for _, char := range chars[1:] {
			current := make([]float64, len(value))
			bestGap := math.Inf(1)
			for i, candidate := range value {
				current[i] = math.Inf(1)
				if i > 0 {
					bestGap = math.Min(bestGap, previous[i-1]-2*float64(i-1))
				}
				if candidate != char || math.IsInf(bestGap, 1) {
					continue
				}
				bonus := 0.0
				if boundary(i) {
					bonus = 6
				}
				current[i] = bestGap + 2*float64(i-1) - bonus
				if i > 0 {
					current[i] = math.Min(current[i], previous[i-1]-3-bonus)
				}
			}
			previous = current
		}
		score := math.Inf(1)
		for _, candidate := range previous {
			score = math.Min(score, candidate)
		}
		if math.IsInf(score, 1) {
			return 0, false
		}
		total += score + lengthPenalty
	}
	return total, true
}

func rankedMatch(primary, secondary, query string) (float64, bool) {
	best := math.Inf(1)
	for i, text := range []string{primary, secondary, primary + " " + secondary} {
		if score, ok := FuzzyScore(text, query); ok {
			if i > 0 {
				score += 35
			}
			best = math.Min(best, score)
		}
	}
	return best, !math.IsInf(best, 1)
}
