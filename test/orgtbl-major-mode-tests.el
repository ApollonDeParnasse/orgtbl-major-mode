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
  (-let* ((test-row-count (generate-random-nat-number-in-range (list 2 10)))
	  (test-row-number (generate-random-nat-number-in-range (list 1 test-row-count)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table-with-hlines (list (cl-constantly test-cell-value) test-row-count test-column-count)  				     
				   (org-table-goto-line-column test-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (setq test-beg (point))
				   (org-table-goto-column test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org-no-properties-and-trim (org-table-get-field (generate-random-nat-number-in-range (list test-beg-column-number test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-left ()
  (-let* ((test-row-count (generate-random-nat-number-in-range (list 2 10)))
	  (test-row-number (generate-random-nat-number-in-range (list 1 test-row-count)))
	  (test-end-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table-with-hlines (list (cl-constantly "1") test-row-count test-column-count)  				     
				   (org-table-goto-line-column test-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (org-table-align)
				   (setq test-beg (point))
				   (org-table-goto-column test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org-no-properties-and-trim (org-table-get-field (generate-random-nat-number-in-range (list test-end-column-number (1- test-beg-column-number))))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-down-right ()
  (-let* ((test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))  	  
	  (test-beg-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-row-number (generate-random-nat-number-in-range (list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))
	  (test-row-count (generate-random-nat-number-in-range (list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table-with-hlines (list (cl-constantly "1") test-row-count test-column-count)  				     
				   (org-table-goto-line-column test-beg-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (setq test-beg (point))
				   (org-table-goto-line-column test-end-row-number test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org-no-properties-and-trim (org-table-get (generate-random-nat-number-in-range (list (1+ test-beg-row-number) test-end-row-number))
							       (generate-random-nat-number-in-range (list (1+ test-beg-column-number) test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-up-left ()
  (-let* ((test-end-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-row-number (generate-random-nat-number-in-range (list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-row-count (generate-random-nat-number-in-range (list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))  	  
	  (test-end-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table-with-hlines (list (cl-constantly "1") test-row-count test-column-count)  				     
				   (org-table-goto-line-column test-beg-row-number test-beg-column-number)
				   (org-table-get-field nil test-cell-value)
				   (org-table-align)
				   (setq test-beg (point))
				   (org-table-goto-line-column test-end-row-number test-end-column-number)
				   (setq test-end (point))
				   (org-table-autofill test-beg test-end)
				   (org-table-align)
				   (org-no-properties-and-trim (org-table-get (generate-random-nat-number-in-range (list test-end-row-number (1- test-beg-row-number)))
							       (generate-random-nat-number-in-range (list test-end-column-number (1- test-beg-column-number))))))
	    test-cell-value))))

(defalias 'org-table--flipped-elt (-flip elt))
(generate-ert-deftest-n-times org-table-map-cells ()
  (-let* (((test-row-col &as test-row-count test-column-count) (generate--times-no-args 2 (generate-random-nat-number-in-range (list 1 10))))
	  ((test-row-number test-column-number) (mapcar #'generate--random-nat-number-between-0-and test-row-col))
	  (test-cell-value (generate-random-word))
	  (actual-cells '()))
    (generate-with-buffer-with-org-table-with-hlines (list (cl-constantly test-cell-value) test-row-count test-column-count)
      (org-table-map-cells (lambda (cell-value cell-row cell-col) (push (list cell-value cell-row cell-col) actual-cells))))
    (should (thread-last actual-cells (-group-by #'-second-item) (org-table--flipped-elt test-row-number) (org-table--flipped-elt test-col-number)))))

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
