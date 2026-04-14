;;; orgtbl-major-mode-tests.el --- Time tracking with org-tables -*- lexical-binding: t; -*-

;; Author: Earl Chase
;; Maintainer: Earl Chase
;; Version: 0.0
;; Keywords: time

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Track your time

;;; Code:

(require 'org-table)
(require 'orgtbl-major-mode)
(load "~/.config/emacs/lib/generate/generate.el")

(generate-ert-deftest-n-times org-table-autofill-string-right ()
  :num-runs 0
  (-let* ((test-row-count (generate-random-nat-number-in-range (list 2 10)))
	  (test-row-number (generate-random-nat-number-in-range (list 1 test-row-count)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value) test-row-count test-column-count)
				   (org-table--goto-row-column test-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (setq test-beg (point))
				   (org-table-goto-column test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org--no-properties-and-trim (org-table-get-field (generate-random-nat-number-in-range (list test-beg-column-number test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-left ()
  :num-runs 0
  (-let* ((test-row-count (generate-random-nat-number-in-range (list 2 10)))
	  (test-row-number (generate-random-nat-number-in-range (list 1 test-row-count)))
	  (test-end-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly "1") test-row-count test-column-count)
				   (org-table--goto-row-column test-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (org-table-align)
				   (setq test-beg (point))
				   (org-table-goto-column test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org--no-properties-and-trim (org-table-get-field (generate-random-nat-number-in-range (list test-end-column-number (1- test-beg-column-number))))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-down-right ()
  :num-runs 0
  (-let* ((test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-beg-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-row-number (generate-random-nat-number-in-range (list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))
	  (test-row-count (generate-random-nat-number-in-range (list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly "1") test-row-count test-column-count)
				   (org-table--goto-row-column test-beg-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (setq test-beg (point))
				   (org-table--goto-row-column test-end-row-number test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org--no-properties-and-trim (org-table-get (generate-random-nat-number-in-range (list (1+ test-beg-row-number) test-end-row-number))
							       (generate-random-nat-number-in-range (list (1+ test-beg-column-number) test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-up-left ()
  :num-runs 0
  (-let* ((test-end-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-row-number (generate-random-nat-number-in-range (list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-row-count (generate-random-nat-number-in-range (list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))
	  (test-end-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly "1") test-row-count test-column-count)
				   (org-table--goto-row-column test-beg-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (org-table-align)
				   (setq test-beg (point))
				   (org-table--goto-row-column test-end-row-number test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org--no-properties-and-trim (org-table-get (generate-random-nat-number-in-range (list test-end-row-number (1- test-beg-row-number)))
							       (generate-random-nat-number-in-range (list test-end-column-number (1- test-beg-column-number))))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table--count-rows ()
  :num-runs 0
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (test-cell-value (generate-random-word))
	  (actual-row-count (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value) test-row-count test-column-count) (org-table--count-rows))))
    (should (equal actual-row-count test-row-count))))

(generate-ert-deftest-n-times org-table--count-cols ()
  :num-runs 0
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (test-cell-value (generate-random-word))
	  (actual-column-count (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value) test-row-count test-column-count) (org-table--count-cols))))
    (should (equal actual-column-count test-column-count))))

(generate-ert-deftest-n-times org-table--map-cells ()
  :num-runs 0
  (-let* (((test-row-col &as test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-10))
	  ((test-row-number test-column-number) (mapcar #'generate--random-nat-number-between-0-and test-row-col))
	  ((test-table test-cells) (generate--org-table (-compose #'number-to-string #'car) test-row-count test-column-count))
	  (test-clean-cells (-remove (-partial #'equal 'hline) test-cells))
	  (expected-val (nth test-column-number (nth test-row-number test-clean-cells)))
	  (actual-table '()))
    (generate-buffer-with-text test-table
      (org-mode)
      (org-table--map-cells (-lambda ((row col)) (push (list (org-table-get row col) (1- row)) actual-table))))
    (should (equal (car (nth test-column-number (reverse (map-elt (-group-by #'cadr actual-table) test-row-number)))) expected-val))))

(generate-ert-deftest-n-times org-table-get-rows-as-list ()
  :num-runs 0
  (-let* ((test-total-rows-to-select (generate--random-nat-number-in-range-10))
	  (test-index-of-start-row-to-select (generate--random-nat-number-in-range-0-10))
	  (test-index-of-end-row-to-select (+ test-total-rows-to-select test-index-of-start-row-to-select))
	  (test-total-rows (+ test-total-rows-to-select test-index-of-start-row-to-select (generate--random-nat-number-in-range-0-10)))
	  (test-total-columns (generate--random-nat-number-in-range-10))
	  ((test-table test-cells) (generate--org-table (-compose #'number-to-string #'car) test-total-rows test-total-columns))
	  (test-clean-cells (-remove (-partial #'equal 'hline) test-cells))
	  (expected-random-row-number (generate--random-nat-number-between-0-and test-total-rows-to-select))
	  (test-random-row-number (+ test-index-of-start-row-to-select expected-random-row-number))
	  (expected-random-row-value (nth test-random-row-number test-clean-cells))
	  (actual-rows))
    (generate-buffer-with-text test-table
      (org-mode)
      (setq actual-rows (org-table-get-rows-as-list (1+ test-index-of-start-row-to-select) (1+ test-index-of-end-row-to-select))))
    (should (equal (nth expected-random-row-number actual-rows) expected-random-row-value))))

(generate-ert-deftest-n-times org-table-replace-selected-rows-no-previous-values ()  
  :num-runs 0
    (let* ((test-plus-start-row (generate--random-nat-number-in-range-0-10))
	   (test-index-of-start-row-to-replace (generate--random-nat-number-in-range-10))
	   (test-index-of-end-row-to-replace (+ test-plus-start-row test-index-of-start-row-to-replace))
	   (test-plus (generate--random-nat-number-in-range-0-10))
	   (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace)))
	   (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	   (test-total-columns (generate--random-nat-number-in-range-10))
	   (test-random-row-num (generate-random-nat-number-in-range (list test-index-of-start-row-to-replace test-index-of-end-row-to-replace)))
	   (test-random-column-num (generate--random-nat-number-between-0-and test-total-columns))
	   (test-replacement-row (generate-list-of-n-words test-total-columns))
	   (test-replacement-cells (make-list test-total-rows-to-replace test-replacement-row))
	   (expected-random-cell (nth test-random-column-num test-replacement-row))
	   (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			   (org-table-replace-selected-rows (list test-index-of-start-row-to-replace test-index-of-end-row-to-replace) test-replacement-cells)
			   (org-table-to-lisp)))
	   (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	   (actual-random-cell (nth test-random-column-num (nth (1- test-random-row-num) actual-clean-table))))
      (should (equal (org--no-properties-and-trim actual-random-cell) expected-random-cell))))

(generate-ert-deftest-n-times org-table-replace-selected-rows-with-previous-values ()
  :num-runs 0
  (-let* ((test-index-of-start-row-to-replace (generate--random-nat-number-in-range-0-10))
	  (test-plus-start-row (generate--random-nat-number-in-range-0-10))
	  (test-index-of-end-row-to-replace (+ test-plus-start-row test-index-of-start-row-to-replace 1))
	  (test-plus (generate--random-nat-number-in-range-0-10))
	  (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace)))
	  (test-total-rows (+ test-index-of-start-row-to-replace test-total-rows-to-replace))
	  (test-total-columns (generate--random-nat-number-in-range-10))
	  (test-random-row-num (+ test-index-of-start-row-to-replace (generate--random-nat-number-between-0-and test-total-rows-to-replace)))
	  (test-random-column-num (generate--random-nat-number-between-0-and test-total-columns))	 
	  ((test-table test-cells) (generate--org-table (-compose #'number-to-string #'car) test-total-rows test-total-columns))
	  (test-clean-cells (-remove (-partial #'equal 'hline) test-cells))
	  (test-replacement-row (nth test-random-row-num test-clean-cells))
	  (expected-random-cell (nth test-random-column-num test-replacement-row))
	  (test-replacement-cells (make-list test-total-rows-to-replace test-replacement-row))
	  (test-previous-values (-slice test-clean-cells test-index-of-start-row-to-replace test-index-of-end-row-to-replace))
	  (actual-table (generate-buffer-with-text test-table
			  (org-mode)
			  (org-table-replace-selected-rows (list test-index-of-start-row-to-replace test-index-of-end-row-to-replace) test-replacement-cells test-previous-values)
			  (org-table-to-lisp)))
	  (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	  (actual-random-cell (nth test-random-column-num (nth (1- test-random-row-num) actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) expected-random-cell))))

(generate-ert-deftest-n-times org-table-map-cells ()
  :num-runs 0
  (-let* (((test-row-col &as test-total-rows test-total-columns) (generate--two-random-nat-numbers-in-range-10))
	  ((test-row-number test-column-number) (mapcar #'generate--random-nat-number-between-0-and test-row-col))
	  (test-colors (generate-list-of-n-colors test-total-rows))
	  (expected-val (nth test-row-number test-colors))
	  (random-number-color-pairs (-zip-with (lambda (i color) (cons (number-to-string i) (propertize (number-to-string i) :background color))) (-iota test-total-rows 1) test-colors))
	  (test-func (-partial #'map-elt random-number-color-pairs))
	  (actual-cell
	   (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
	     (org-table-map-cells test-func)
	     (org-table-get (1+ test-row-number) (1+ test-column-number)))))
    (should (equal (get-text-property 0 :background actual-cell) expected-val))))

(generate-ert-deftest-n-times org-table-map-selected-rows ()
  :num-runs 0
  (-let* ((test-count-of-rows-to-map (generate--random-nat-number-in-range-10))
	 (test-index-of-start-row-to-map (generate--random-nat-number-in-range-10))
	 (test-index-of-end-row-to-map (+ test-count-of-rows-to-map test-index-of-start-row-to-map))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-map (- test-index-of-end-row-to-map test-index-of-start-row-to-map) test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 ((test-row-number test-column-number) (mapcar #'generate-random-nat-number-in-range (list (list test-index-of-start-row-to-map (1+ test-index-of-end-row-to-map)) (list 1 test-total-columns))))
	 (test-colors (generate-list-of-n-colors test-total-rows))
	 (expected-val (nth (1- test-row-number) test-colors))
	 (random-number-color-pairs (-zip-with (lambda (i color) (cons (number-to-string i) (propertize (number-to-string i) :background color))) (-iota test-total-rows 1) test-colors))
	 (test-func (-partial #'map-elt random-number-color-pairs))
	 (actual-cell (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-map-selected-rows test-func (list test-index-of-start-row-to-map test-index-of-end-row-to-map))
			 (org-table-get test-row-number test-column-number))))
	 (should (equal (get-text-property 0 :background actual-cell) expected-val))))

(generate-ert-deftest-n-times org-table-edit-rows-without-header ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate--random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace (generate--random-nat-number-in-range-10))
	 (test-index-of-end-row-to-replace (+ test-count-of-rows-to-replace test-index-of-start-row-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (generate--random-nat-number-between-1-and test-count-of-rows-to-replace))
	 (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	 (expected-edited-row-num (+ test-index-of-start-row-to-replace test-edit-buffer-line-num-to-replace -2))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line test-index-of-start-row-to-replace)
			 (setq beg (point))
			 (org-table-goto-line test-index-of-end-row-to-replace)
			 (setq end (point))
			 (org-table-edit-rows beg end nil)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put test-edit-buffer-line-num-to-replace (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c C-k"))
			 (org-table-to-lisp)))
	 (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
  (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-rows-with-header-and-without-first-row-in-selection ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate--random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace (1+ (generate--random-nat-number-in-range-10)))
	 (test-index-of-end-row-to-replace (+ test-count-of-rows-to-replace test-index-of-start-row-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (1+ (generate-random-nat-number-in-range (list 1 test-count-of-rows-to-replace))))
	 (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	 (expected-edited-row-num (+ test-index-of-start-row-to-replace test-edit-buffer-line-num-to-replace -2))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line test-index-of-start-row-to-replace)
			 (setq beg (point))
			 (org-table-goto-line test-index-of-end-row-to-replace)
			 (setq end (point))
			 (org-table-edit-rows beg end)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put test-edit-buffer-line-num-to-replace (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c C-k"))
			 (org-table-to-lisp)))
	 (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
  (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-rows-with-header-and-with-first-row-in-selection ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate--random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace 1)
	 (test-index-of-end-row-to-replace (1+ test-count-of-rows-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (generate--random-nat-number-between-1-and test-count-of-rows-to-replace))
	 (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	 (expected-edited-row-num (+ test-index-of-start-row-to-replace test-edit-buffer-line-num-to-replace -2))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line 1)
			 (setq beg (point))
			 (org-table-goto-line test-index-of-end-row-to-replace)
			 (setq end (point))
			 (org-table-edit-rows beg end)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put test-edit-buffer-line-num-to-replace (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c C-k"))
			 (org-table-to-lisp)))
	 (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
  (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-without-header ()
  :num-runs 100
  (let* ((test-index-of-row-to-replace (generate--random-nat-number-in-range-10))
	 (test-plus (generate--random-nat-number-in-range-10))
	 (test-total-rows (+ test-index-of-row-to-replace test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line (1+ test-index-of-row-to-replace))
			 (org-table-edit-current-row (point) 'nil)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put 1 (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c C-k"))
			 (org-table-to-lisp)))
	 (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth test-index-of-row-to-replace actual-clean-table))))
  (should (string-equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-with-header ()
  :num-runs 100
  (let* ((test-index-of-row-to-replace (generate-random-nat-number-in-range (list 2 10)))
	 (test-plus (generate--random-nat-number-in-range-10))
	 (test-total-rows (+ test-index-of-row-to-replace test-plus))
	 (test-total-columns (generate--random-nat-number-in-range-10))
	 (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line (1+ test-index-of-row-to-replace))
			 (org-table-edit-current-row (point) 't)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put 2 (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c C-k"))
			 (org-table-to-lisp)))
	 (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth test-index-of-row-to-replace actual-clean-table))))
  (should (string-equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-with-header-and-with-first-row-in-selection ()
  :num-runs 100
  (-let* (((test-total-rows test-total-columns) (generate--two-random-nat-numbers-in-range-10))
	  (expected-edited-col-num (generate--random-nat-number-between-0-and test-total-columns))
	  (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			  (org-table-goto-line 1)
			  (org-table-edit-current-row (point) 't)
			  (dotimes (test-col-num test-total-columns)
			    (org-table-put 1 (1+ test-col-num) "EDITED"))
			  (org-table-align)
			  (funcall (keymap-local-lookup "C-c C-k"))
			  (org-table-to-lisp)))
	  (actual-clean-table (-remove (-partial #'equal 'hline) actual-table))
	  (actual-random-cell (nth expected-edited-col-num (car actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(defconst SINGLE-ROW-ALIGN-TESTS
  (list (cons "| a |\n" "|   a |")
	 (cons "|----|" "|----|")
	 (cons "|---|---|---|" "|---|---|---|")
	 (cons "  | a |\n" "  |   a |")
	 (cons "  | a | b |\n" "  |   a | b |")
	 (cons "| a        | b |" "| a | b |")))

(defconst BASIC-ALIGN-TESTS
  (list (cons "| a |\n" "|   a |")
	 (cons "  | a |\n" "  |   a |")
	 (cons "| 123 |\n|-----|\n" "| 123 |\n|-|")
	 (cons "| a | b |\n|---+---|\n" "| a | b |\n|-+-|")
	 (cons "| a   | bc |\n| bcd |    |\n" "| a | bc |\n| bcd |  |")
	 (cons "| abc | bc  |\n|     | bcd |\n" "| abc | bc |\n| | bcd |")
	 (cons "| a | b |\n| c |   |\n" "| a | b |\n| c |")
	 (cons "| a | b |\n|---+---|\n" "| a | b |\n|---|")))

(defconst ALIGNMENT-COOKIE-TEST
  (list (cons "|   1 |\n|  12 |\n| abc |" "| 1 |\n| 12 |\n| abc |")
	 (cons "| 1   |\n| ab  |\n| abc |" "| 1 |\n| ab |\n| abc |")
	 (cons "| <r> |\n|  ab |\n| abc |" "| <r> |\n| ab |\n| abc |")
	 (cons "| <l> |\n| 12  |\n| 123 |" "| <l> |\n| 12 |\n| 123 |")
	 (cons "| <c> |\n|  1  |\n| 123 |" "| <c> |\n| 1 |\n| 123 |")))
