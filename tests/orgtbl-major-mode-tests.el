;;; orgtbl-major-mode-tests.el --- Time tracking with org-tables -*- lexical-binding: t; -*-

;; Author: Earl Chase
;; Maintainer: Earl Chase
;; Version: 0.0
;; Keywords: tables
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

;; Test for orgtbl-major-mode

;;; Code:

(require 'org-table)
(require 'orgtbl-major-mode)
(require 'generator)
(require 'generate)

(generate-ert-deftest-n-times org-table-autofill-string-right ()
  :num-runs 100
  (-let* ((test-row-count (generate-random-nat-number-in-range (list 2 10)))
	  (test-row-number (generate-random-nat-number-in-range (list 1 test-row-count)))
	  (test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value)
						       test-row-count test-column-count)
	      (org-table--goto-row-column test-row-number test-beg-column-number)
	      (org-table-get-field nil test-cell-value)
	      (setq test-beg (point))
	      (org-table-goto-column test-end-column-number)
	      (setq test-end (point))
	      (org-table-autofill test-beg test-end)
	      (org-table-align)
	      (org--no-properties-and-trim (org-table-get-field
					    (generate-random-nat-number-in-range
					     (list test-beg-column-number test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-left ()
  :num-runs 100
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
	      (org--no-properties-and-trim (org-table-get-field
					    (generate-random-nat-number-in-range
					     (list test-end-column-number (1- test-beg-column-number))))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-down-right ()
  :num-runs 100
  (-let* ((test-beg-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-column-number (generate-random-nat-number-in-range
				   (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-column-count (generate-random-nat-number-in-range
			      (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-beg-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-end-row-number (generate-random-nat-number-in-range
				(list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))
	  (test-row-count (generate-random-nat-number-in-range
			   (list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly "1")
						       test-row-count
						       test-column-count)
	      (org-table--goto-row-column test-beg-row-number test-beg-column-number)
	      (org-table-get-field nil test-cell-value)
	      (setq test-beg (point))
	      (org-table--goto-row-column test-end-row-number test-end-column-number)
	      (setq test-end (point))
	      (org-table-autofill test-beg test-end)
	      (org-table-align)
	      (org--no-properties-and-trim (org-table-get
					    (generate-random-nat-number-in-range
					     (list (1+ test-beg-row-number)
						   test-end-row-number))
					    (generate-random-nat-number-in-range
					     (list (1+ test-beg-column-number)
						   test-end-column-number)))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table-autofill-string-up-left ()
  :num-runs 100
  (-let* ((test-end-row-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-row-number (generate-random-nat-number-in-range
				(list (1+ test-end-row-number) (+ 10 test-end-row-number))))
	  (test-row-count (generate-random-nat-number-in-range
			   (list (1+ test-beg-row-number) (+ 10 test-beg-row-number))))
	  (test-end-column-number (generate-random-nat-number-in-range (list 1 10)))
	  (test-beg-column-number (generate-random-nat-number-in-range
				   (list (1+ test-end-column-number) (+ 10 test-end-column-number))))
	  (test-column-count (generate-random-nat-number-in-range
			      (list (1+ test-beg-column-number) (+ 10 test-beg-column-number))))
	  (test-cell-value (generate-random-word)))
    (should
     (equal (generate-with-buffer-with-org-table (list (cl-constantly "1")
						       test-row-count
						       test-column-count)
	      (org-table--goto-row-column test-beg-row-number test-beg-column-number)
	      (org-table-get-field nil test-cell-value)
	      (org-table-align)
	      (setq test-beg (point))
	      (org-table--goto-row-column test-end-row-number test-end-column-number)
	      (setq test-end (point))
	      (org-table-autofill test-beg test-end)
	      (org-table-align)
	      (org--no-properties-and-trim (org-table-get
					    (generate-random-nat-number-in-range
					     (list test-end-row-number
						   (1- test-beg-row-number)))
					    (generate-random-nat-number-in-range
					     (list test-end-column-number
						   (1- test-beg-column-number))))))
	    test-cell-value))))

(generate-ert-deftest-n-times org-table--count-rows ()
  :num-runs 100
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (test-cell-value (generate-random-word))
	  (actual-row-count (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value)
								       test-row-count test-column-count)
			      (org-table--count-rows))))
    (should (equal actual-row-count test-row-count))))

(generate-ert-deftest-n-times org-table--count-cols ()
  :num-runs 100
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (test-cell-value (generate-random-word))
	  (actual-column-count (generate-with-buffer-with-org-table (list (cl-constantly test-cell-value)
									  test-row-count test-column-count)
				 (org-table--count-cols))))
    (should (equal actual-column-count test-column-count))))

(generate-ert-deftest-n-times org-table--map-cells ()
  :num-runs 100
  (-let* (((test-row-col &as test-row-count test-column-count) (generate-two-random-nat-numbers-in-range-10))
	  ((test-row-number test-column-number) (mapcar #'generate-random-nat-number-between-0-and test-row-col))
	  ((test-table test-cells) (generate-org-table-mv (-compose #'number-to-string #'car)
							  test-row-count test-column-count))
	  (test-clean-cells (org-table--remove-hlines-from-list test-cells))
	  (expected-val (nth test-column-number (nth test-row-number test-clean-cells)))
	  (actual-table '()))
    (generate-with-buffer-with-text test-table
      (org-mode)
      (org-table--map-cells (-lambda ((row col)) (push (list (org-table-get row col) (1- row))
						       actual-table))))
    (let ((actual-val
	  (->> test-row-number
	       (map-elt (-group-by #'cadr actual-table))
	       (reverse)
	       (nth test-column-number)
	       (car))))
      (should (equal actual-val expected-val)))))

(generate-ert-deftest-n-times org-table--create-reverse-iterator ()
  :num-runs 100
  (-let* (((test-row-col &as test-row-count test-column-count) (generate-two-random-nat-numbers-in-range-10))
	  (expected-cell (mapcar #'generate-random-nat-number-between-1-and test-row-col))
	  (expected-length (* test-row-count test-column-count))
	  (actual-iterator (org-table--create-reverse-iterator
			    test-row-count
			    test-column-count))
	  (actual-values '()))
    (iter-do (row-col actual-iterator)
      (push row-col actual-values))
    (should (length= actual-values expected-length))
    (should (seq-contains-p actual-values expected-cell))
    (should (equal (car actual-values) (list 1 1)))))

(generate-ert-deftest-n-times org-table-get-rows-as-list ()
  :num-runs 100
  (-let* ((test-total-rows-to-select (generate-random-nat-number-in-range-10))
	  (test-index-of-start-row-to-select (generate--random-nat-number-in-range-0-10))
	  (test-index-of-end-row-to-select (+ test-total-rows-to-select
					      test-index-of-start-row-to-select))
	  (test-total-rows (+ test-total-rows-to-select
			      test-index-of-start-row-to-select
			      (generate--random-nat-number-in-range-0-10)))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  ((test-table test-cells) (generate-org-table-mv
				    (-compose #'number-to-string #'car)
				    test-total-rows
				    test-total-columns))
	  (test-clean-cells (org-table--remove-hlines-from-list test-cells))
	  (expected-random-row-number (generate-random-nat-number-between-0-and
				       test-total-rows-to-select))
	  (test-random-row-number (+ test-index-of-start-row-to-select expected-random-row-number))
	  (expected-random-row-value (nth test-random-row-number test-clean-cells))
	  (actual-rows))
    (generate-with-buffer-with-text test-table
      (org-mode)
      (setq actual-rows (org-table-get-rows-as-list (1+ test-index-of-start-row-to-select)
						    (1+ test-index-of-end-row-to-select))))
    (should (equal (nth expected-random-row-number actual-rows)
		   expected-random-row-value))))

(generate-ert-deftest-n-times org-table-replace-selected-rows-no-previous-values ()
  :num-runs 100
  (let* ((test-plus-start-row (generate--random-nat-number-in-range-0-10))
	 (test-index-of-start-row-to-replace (generate-random-nat-number-in-range-10))
	 (test-index-of-end-row-to-replace (+ test-plus-start-row test-index-of-start-row-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace
					    test-index-of-start-row-to-replace)))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace
								   test-index-of-start-row-to-replace)
			     test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (test-random-row-num (generate-random-nat-number-in-range (list test-index-of-start-row-to-replace
									 test-index-of-end-row-to-replace)))
	 (test-random-column-num (generate-random-nat-number-between-0-and test-total-columns))
	 (test-replacement-row (generate-list-of-n-words test-total-columns))
	 (test-replacement-cells (make-list test-total-rows-to-replace test-replacement-row))
	 (expected-random-cell (nth test-random-column-num test-replacement-row))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car)
								  test-total-rows
								  test-total-columns)
			 (org-table-replace-selected-rows (list test-index-of-start-row-to-replace
								test-index-of-end-row-to-replace)
							  test-replacement-cells)
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth test-random-column-num (nth (1- test-random-row-num)
							      actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell)
		   expected-random-cell))))

(generate-ert-deftest-n-times org-table-replace-selected-rows-with-previous-values ()
  :num-runs 100
  (-let* ((test-index-of-start-row-to-replace (generate--random-nat-number-in-range-0-10))
	  (test-plus-start-row (generate--random-nat-number-in-range-0-10))
	  (test-index-of-end-row-to-replace (+ test-plus-start-row test-index-of-start-row-to-replace 1))
	  (test-plus (generate--random-nat-number-in-range-0-10))
	  (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace)))
	  (test-total-rows (+ test-index-of-start-row-to-replace test-total-rows-to-replace))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  (test-random-row-num (+ test-index-of-start-row-to-replace (generate-random-nat-number-between-0-and test-total-rows-to-replace)))
p	  (test-random-column-num (generate-random-nat-number-between-0-and test-total-columns))
	  ((test-table test-cells) (generate-org-table-mv (-compose #'number-to-string #'car) test-total-rows test-total-columns))
	  (test-clean-cells (org-table--remove-hlines-from-list test-cells))
	  (test-replacement-row (nth test-random-row-num test-clean-cells))
	  (expected-random-cell (nth test-random-column-num test-replacement-row))
	  (test-replacement-cells (make-list test-total-rows-to-replace test-replacement-row))
	  (test-previous-values (-slice test-clean-cells test-index-of-start-row-to-replace test-index-of-end-row-to-replace))
	  (actual-table (generate-with-buffer-with-text test-table
			  (org-mode)
			  (org-table-replace-selected-rows
			   (list test-index-of-start-row-to-replace test-index-of-end-row-to-replace)
			   test-replacement-cells
			   test-previous-values)
			  (org-table-to-lisp)))
	  (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	  (actual-random-cell (nth test-random-column-num (nth (1- test-random-row-num) actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) expected-random-cell))))

(generate-ert-deftest-n-times org-table-map-cells ()
  :num-runs 100
  (-let* (((test-row-col &as test-total-rows test-total-columns) (generate-two-random-nat-numbers-in-range-10))
	  ((test-row-number test-column-number) (mapcar #'generate-random-nat-number-between-0-and test-row-col))
	  (test-colors (generate-list-of-n-colors test-total-rows))
	  (expected-val (nth test-row-number test-colors))
	  (random-number-color-pairs (-zip-with (lambda (i color) (cons (number-to-string i)
									(propertize (number-to-string i) :background color)))
						(-iota test-total-rows 1) test-colors))
	  (test-func (-partial #'map-elt random-number-color-pairs))
	  (actual-cell
	   (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car)
						      test-total-rows test-total-columns)
	     (org-table-map-cells test-func)
	     (org-table-get (1+ test-row-number) (1+ test-column-number)))))
    (should (equal (get-text-property 0 :background actual-cell) expected-val))))

(generate-ert-deftest-n-times org-table-map-selected-rows ()
  :num-runs 100
  (-let* ((test-count-of-rows-to-map (generate-random-nat-number-in-range-10))
	  (test-index-of-start-row-to-map (generate-random-nat-number-in-range-10))
	  (test-index-of-end-row-to-map (+ test-count-of-rows-to-map test-index-of-start-row-to-map))
	  (test-plus (generate--random-nat-number-in-range-0-10))
	  (test-total-rows (+ test-index-of-start-row-to-map (- test-index-of-end-row-to-map
								test-index-of-start-row-to-map)
			      test-plus))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  ((test-row-number test-column-number) (mapcar #'generate-random-nat-number-in-range
							(list (list test-index-of-start-row-to-map
								    (1+ test-index-of-end-row-to-map))
							      (list 1 test-total-columns))))
	  (test-colors (generate-list-of-n-colors test-total-rows))
	  (expected-val (nth (1- test-row-number) test-colors))
	  (random-number-color-pairs (-zip-with (lambda (i color)
						  (cons (number-to-string i)
							(propertize (number-to-string i)
								    :background color)))
						(-iota test-total-rows 1) test-colors))
	  (test-func (-partial #'map-elt random-number-color-pairs))
	  (actual-cell (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car)
								  test-total-rows test-total-columns)
			 (org-table-map-selected-rows test-func (list test-index-of-start-row-to-map
								      test-index-of-end-row-to-map))
			 (org-table-get test-row-number test-column-number))))
    (should (equal (get-text-property 0 :background actual-cell) expected-val))))

(generate-ert-deftest-n-times org-table-replace-region/single-row ()
  :num-runs 100
  (-let* ((test-index-of-row-to-replace (generate-random-nat-number-in-range-10))
	  (test-plus (generate-random-nat-number-in-range-10))
	  (test-total-rows (+ test-index-of-row-to-replace test-plus))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  ((test-replacement-row (expected-replacement-values)) (generate-org-table-mv
								 (-compose #'number-to-string #'1+ #'car)
								 1
								 test-total-columns))
	  (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
	  (expected-value (nth expected-edited-col-num expected-replacement-values))
	  (actual-table (generate-with-buffer-with-org-table (list
							      (-compose #'number-to-string #'1+ #'car)
							      test-total-rows
							      test-total-columns)
			  (org-table-replace-region
			   (1+ test-index-of-row-to-replace)
			   (1+ test-index-of-row-to-replace)
			   test-replacement-row)
			  (org-table-to-lisp)))
	  (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	  (actual-random-cell (nth expected-edited-col-num expected-replacement-values)))
    (should (string-equal (org--no-properties-and-trim actual-random-cell) expected-value))))

(generate-ert-deftest-n-times org-table-replace-region/multiple-rows/no-hlines ()
  :num-runs 100
  (-let* ((test-index-of-start-row-to-replace (generate-random-nat-number-in-range-10))
	  (test-plus (generate-random-nat-number-in-range-10))
	  (test-index-of-end-row-to-replace (+ test-index-of-start-row-to-replace test-plus))
	  (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace
					     test-index-of-start-row-to-replace)))
	  (test-total-rows (+ test-total-rows-to-replace
			      test-index-of-start-row-to-replace
			      (generate-random-nat-number-in-range-10)))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  ((test-replacement-rows expected-edited-slice)
	   (generate-org-table-without-hlines-mv
	    (-lambda ((x y)) (format "EDITED%s%s" x y))
	    test-total-rows-to-replace
	    test-total-columns))
	  (actual-table (generate-with-buffer-with-org-table-without-hlines
			    (list
			     (-compose #'number-to-string #'1+ #'car)
			     test-total-rows
			     test-total-columns)

			  (org-table-replace-region
			   (1+ test-index-of-start-row-to-replace)
			   (1+ test-index-of-end-row-to-replace)
			   test-replacement-rows)
			  (org-table-to-lisp)))
	  (actual-edited-slice (-slice actual-table
				       test-index-of-start-row-to-replace
				       (1+ test-index-of-end-row-to-replace)))
	  (test-random-row (generate-random-nat-number-between-0-and
			    test-total-rows-to-replace))
	  (test-random-col (generate-random-nat-number-between-0-and
			    test-total-columns))
	  (actual-value
	   (nth
	    test-random-col
	    (nth test-random-row actual-edited-slice)))
	  (expected-value
	   (nth
	    test-random-col
	    (nth test-random-row expected-edited-slice))))
    (should (equal actual-value expected-value))))

(generate-ert-deftest-n-times org-table-replace-region/multiple-rows/with-hlines ()
  :num-runs 100
  (-let* ((test-index-of-start-row-to-replace (generate-random-nat-number-in-range-10))
	  (test-plus (generate-random-nat-number-in-range-10))
	  (test-index-of-end-row-to-replace (+ test-index-of-start-row-to-replace test-plus))
	  (test-total-rows-to-replace (1+ (- test-index-of-end-row-to-replace
					     test-index-of-start-row-to-replace)))
	  (test-total-rows (+ test-total-rows-to-replace
			      test-index-of-start-row-to-replace
			      (generate-random-nat-number-in-range-10)))
	  (test-total-columns (generate-random-nat-number-in-range-10))
	  ((test-replacement-rows expected-edited-slice)
	   (generate-org-table-with-hlines-mv
	    (-lambda ((x y)) (format "EDITED%s%s" x y))
	    test-total-rows-to-replace
	    test-total-columns))
	  (actual-table (generate-with-buffer-with-org-table-with-hlines
			    (list
			     (-compose #'number-to-string #'1+ #'car)
			     test-total-rows
			     test-total-columns)

			  (org-table-replace-region
			   (1+ test-index-of-start-row-to-replace)
			   (1+ test-index-of-end-row-to-replace)
			   test-replacement-rows)
			  (org-table-to-lisp)))
	  (actual-edited-slice (-slice actual-table
				       test-index-of-start-row-to-replace
				       (1+ test-index-of-end-row-to-replace)))
	  (test-random-row (generate-random-nat-number-between-0-and
			    test-total-rows-to-replace))
	  (test-random-col (generate-random-nat-number-between-0-and
			    test-total-columns))
	  (actual-value
	   (nth
	    test-random-col
	    (nth test-random-row
		 (org-table--remove-hlines-from-list actual-table))))
	  (expected-value
	   (nth
	    test-random-col
	    (nth test-random-row
		 (org-table--remove-hlines-from-list actual-table)))))
    (should (equal actual-value expected-value))))

(generate-ert-deftest-n-times org-table--get-cell-index ()
  :num-runs 100
  (-let* (((test-row-count test-column-count) (generate-two-random-nat-numbers-in-range-10))
	  ((test-table test-cells) (generate-org-table-mv (-lambda ((x y)) (format "%s:%s" (- x 1) (- y 1)))
							test-row-count test-column-count))
	  ((test-random-cell-value expected-cell-index) (thread-last test-cells
					 (org-table--remove-hlines-from-list)
					 (flatten-tree)
					 (generate-seq-random-value-with-position)))
	  (test-cell-addr (mapcar #'string-to-number
				  (s-split ":" test-random-cell-value)))
	  (actual-cell-index
	   (generate-with-buffer-with-text test-table
	     (org-mode)
	     (re-search-forward test-random-cell-value)
	     (org-table--get-cell-index))))
	  (should (equal actual-cell-index expected-cell-index))))

(generate-ert-deftest-n-times org-table--goto-cell-index ()
  :num-runs 100
  (-let* (((test-table _ test-row-count test-column-count)
	   (generate-random-org-table-mv))
	  (test-total-cells (* test-row-count test-column-count))
	  (test-cell-index (generate-random-nat-number-in-range
			    (list 0 test-total-cells))))
    (generate-with-buffer-with-text test-table
      (org-table--goto-cell-index test-cell-index)
      (should (equal (org-table--get-cell-index) test-cell-index)))))

(generate-ert-deftest-n-times org-table--get-next-cell-row-column/before-last-cell/next-column ()
  :num-runs 100
  (-let* (((test-coordinates &as test-start-row test-start-column)
	   (generate-two-random-nat-numbers-in-range-10))
	  ((expected-coordinates &as test-expected-row test-expected-column)
	   (list test-start-row (1+ test-start-column)))
	  (test-row-count (+ test-expected-row (generate-random-nat-number-in-range (list 0 10))))
	  (test-column-count (+ test-expected-column (generate-random-nat-number-in-range (list 0 10))))
	  (actual-coordinates
	   (org-table--get-next-cell-row-column test-row-count
						test-column-count
						test-coordinates)))
    (should (equal actual-coordinates expected-coordinates))))

(generate-ert-deftest-n-times org-table--get-next-cell-row-column/before-last-cell/next-row ()
  :num-runs 100
  (-let* (((test-coordinates &as test-start-row test-start-column)
	   (generate-two-random-nat-numbers-in-range-10))
	  ((expected-coordinates &as test-expected-row test-expected-column)
	   (list (1+ test-start-row) 1))
	  (test-row-count (+ test-expected-row (generate-random-nat-number-in-range-10)))
	  (actual-coordinates
	   (org-table--get-next-cell-row-column test-row-count
						test-start-column
						test-coordinates)))
    (should (equal actual-coordinates expected-coordinates))))

(generate-ert-deftest-n-times org-table--get-next-cell-row-column/in-last-cell ()
  :num-runs 100
  (-let* (((test-coordinates &as test-rows test-columns)
	   (generate-two-random-nat-numbers-in-range-10))
	  (actual-coordinates
	   (org-table--get-next-cell-row-column test-rows
						test-columns
						test-coordinates)))
    (should (equal actual-coordinates test-coordinates))))

(generate-ert-deftest-n-times org-table--get-previous-cell-row-column/same-row ()
  :num-runs 100
  (-let* (((test-start-row test-expected-column)
	   (generate-two-random-nat-numbers-in-range-10))
	  (test-start-column (1+ test-expected-column))
	  (test-coordinates (list test-start-row test-start-column))
	  (expected-coordinates (list test-start-row test-expected-column))
	  (test-columns (+ test-expected-column (generate-random-nat-number-in-range-10)))
	  (test-rows (+ test-start-row (generate-random-nat-number-in-range (list 1 10))))
	  (actual-coordinates
	   (org-table--get-previous-cell-row-column
	    test-rows
	    test-columns
	    test-coordinates)))
    (should (equal actual-coordinates expected-coordinates))))

(generate-ert-deftest-n-times org-table--get-previous-cell-row-column/first-column/previous-row ()
  :num-runs 100
  (-let* (((expected-row test-columns)
	   (generate-two-random-nat-numbers-in-range-10))
	  (test-start-row (1+ expected-row))
	  (test-coordinates (list test-start-row 1))
	  (test-rows (+ test-start-row (generate-random-nat-number-in-range (list 1 10))))
	  (expected-coordinates (list expected-row test-columns))
	  (actual-coordinates
	   (org-table--get-previous-cell-row-column
	    test-rows
	    test-columns
	    test-coordinates)))
    (should (equal actual-coordinates expected-coordinates))))

(generate-ert-deftest-n-times org-table--get-previous-cell-row-column/in-first-cell ()
  :num-runs 100
  (-let* (((test-rows test-columns)
	   (generate-two-random-nat-numbers-in-range-10))
	  (actual-coordinates
	   (org-table--get-previous-cell-row-column
	    test-rows
	    test-columns
	    (list 1 1))))
    (should (equal actual-coordinates (list 1 1)))))

(generate-ert-deftest-n-times org-table--create-random-partially-filled-table ()
  :num-runs 100
  (-let* (((actual-table actual-cell-index) (org-table--create-random-partially-filled-table))
	  (random-cell-index (generate-random-nat-number-between-0-and actual-cell-index)))
    (generate-with-buffer-with-text actual-table
      (org-table--goto-cell-index actual-cell-index)
      (should (equal (org-trim (org-table-get-field)) ""))
      (org-table--goto-cell-index random-cell-index)
      (should-not (equal (org-table-get-field) "")))))

(defun org-table--create-random-partially-filled-table ()
  (let* ((test-row-count (generate-random-nat-number-in-range (list 1 10)))
	 (test-column-count (generate-random-nat-number-in-range (list 1 10)))
	 (test-total-cell-count (* test-row-count test-column-count))
	 (expected-row-num (generate-random-nat-number-in-range (list 0 test-row-count)))
	 (expected-col-num (generate-random-nat-number-in-range (list 0 test-column-count)))
	 (index-of-first-empty-cell (+ (* test-column-count expected-row-num)
				       expected-col-num))
	 (table-creator (-lambda ((current-row current-col))
			  (if-let* ((current-index (+ (* test-column-count
							 (1- current-row))
						      (1- current-col)))
				    (_ (>= current-index index-of-first-empty-cell)))
			      ""
			    (format "%s" current-index))))
	 (table (generate-org-table table-creator
				    test-row-count
				    test-column-count)))
    (list table index-of-first-empty-cell)))

(generate-ert-deftest-n-times org-table-goto-first-empty-cell-in-table/partially-filled-table ()
  :num-runs 100
  (-let* (((test-table expected-cell-index)
	   (org-table--create-random-partially-filled-table))
	  (actual-cell-index
	   (generate-with-buffer-with-text test-table
	     (org-table-goto-first-empty-cell-in-table)
	     (org-table--get-cell-index))))
    (should (equal actual-cell-index expected-cell-index))))

(generate-ert-deftest-n-times org-table-goto-first-empty-cell-in-table/full-table ()
  :num-runs 100
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (expected-cell-index (1- (* test-row-count test-column-count)))
	  (table-creator (pcase-lambda (`(,row ,col)) (number-to-string row)))
	  (actual-cell-index
	   (generate-with-buffer-with-org-table (list
						 table-creator
						 test-row-count
						 test-column-count)
	     (org-table-goto-first-empty-cell-in-table)
	     (org-table--get-cell-index))))
    (should (equal actual-cell-index expected-cell-index))))

(generate-ert-deftest-n-times org-table-goto-first-empty-cell-in-table/empty-table ()
  :num-runs 100
  (-let* (((test-row-count test-column-count) (generate--two-random-nat-numbers-in-range-25))
	  (expected-cell-index (1- (* test-row-count test-column-count)))
	  (actual-cell-index
	   (generate-with-buffer-with-org-table (list
						 (cl-constantly "")
						 test-row-count
						 test-column-count)
	     (org-table-goto-first-empty-cell-in-table)
	     (org-table--get-cell-index))))
    (should (equal actual-cell-index 0))))

(generate-ert-deftest-n-times org-table-edit-rows-without-header ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate-random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace (generate-random-nat-number-in-range-10))
	 (test-index-of-end-row-to-replace (+ test-count-of-rows-to-replace test-index-of-start-row-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (generate-random-nat-number-between-1-and test-count-of-rows-to-replace))
	 (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
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
			 (funcall (keymap-local-lookup "C-c '"))
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-rows-with-header-and-without-first-row-in-selection ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate-random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace (1+ (generate-random-nat-number-in-range-10)))
	 (test-index-of-end-row-to-replace (+ test-count-of-rows-to-replace test-index-of-start-row-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (1+ (generate-random-nat-number-in-range (list 1 test-count-of-rows-to-replace))))
	 (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
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
			 (funcall (keymap-local-lookup "C-c '"))
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-rows-with-header-and-with-first-row-in-selection ()
  :num-runs 100
  (let* ((test-count-of-rows-to-replace (generate-random-nat-number-in-range-10))
	 (test-index-of-start-row-to-replace 1)
	 (test-index-of-end-row-to-replace (1+ test-count-of-rows-to-replace))
	 (test-plus (generate--random-nat-number-in-range-0-10))
	 (test-total-rows (+ test-index-of-start-row-to-replace (- test-index-of-end-row-to-replace test-index-of-start-row-to-replace) test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (test-edit-buffer-line-num-to-replace (generate-random-nat-number-between-1-and test-count-of-rows-to-replace))
	 (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
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
			 (funcall (keymap-local-lookup "C-c '"))
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth expected-edited-row-num actual-clean-table))))
    (should (equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-without-header ()
  :num-runs 100
  (let* ((test-index-of-row-to-replace (generate-random-nat-number-in-range-10))
	 (test-plus (generate-random-nat-number-in-range-10))
	 (test-total-rows (+ test-index-of-row-to-replace test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
	 (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line (1+ test-index-of-row-to-replace))
			 (org-table-edit-current-row 'nil)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put 1 (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c '"))
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth test-index-of-row-to-replace actual-clean-table))))
    (should (string-equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-with-header ()
  :num-runs 100
  (let* ((test-index-of-row-to-replace (generate-random-nat-number-in-range (list 2 10)))
	 (test-plus (generate-random-nat-number-in-range-10))
	 (test-total-rows (+ test-index-of-row-to-replace test-plus))
	 (test-total-columns (generate-random-nat-number-in-range-10))
	 (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
	 (actual-table (generate-with-buffer-with-org-table-with-hlines (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			 (org-table-goto-line (1+ test-index-of-row-to-replace))
			 (org-table-edit-current-row 't)
			 (dotimes (test-col-num test-total-columns)
			   (org-table-put 2 (1+ test-col-num) "EDITED"))
			 (org-table-align)
			 (funcall (keymap-local-lookup "C-c '"))
			 (org-table-to-lisp)))
	 (actual-clean-table (org-table--remove-hlines-from-list actual-table))
	 (actual-random-cell (nth expected-edited-col-num (nth test-index-of-row-to-replace actual-clean-table))))
    (should (string-equal (org--no-properties-and-trim actual-random-cell) "EDITED"))))

(generate-ert-deftest-n-times org-table-edit-current-row-with-header-and-with-first-row-in-selection ()
  :num-runs 100
  (-let* (((test-total-rows test-total-columns) (generate-two-random-nat-numbers-in-range-10))
	  (expected-edited-col-num (generate-random-nat-number-between-0-and test-total-columns))
	  (actual-table (generate-with-buffer-with-org-table (list (-compose #'number-to-string #'car) test-total-rows test-total-columns)
			  (org-table-goto-line 1)
			  (org-table-edit-current-row 't)
			  (dotimes (test-col-num test-total-columns)
			    (org-table-put 1 (1+ test-col-num) "EDITED"))
			  (org-table-align)
			  (funcall (keymap-local-lookup "C-c '"))
			  (org-table-to-lisp)))
	  (actual-clean-table (org-table--remove-hlines-from-list actual-table))
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
