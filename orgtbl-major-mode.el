;;; orgtbl-major-mode.el --- Orgtbl files -*- lexical-binding: t; -*-

;; Author: Earl Chase
;; Maintainer: Earl Chase
;; Version: 0.0
;; Keywords: org
;; Package-Requires: ((emacs "30") (org "9.7"))
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

;; Tracking

;;; Code: Attempt to use org files with very large org-tables

(require 'org)
(require 'org-table)

(defsubst org-table--goto-line-column (line column)
  (org-table-goto-line line)
  (org-table-goto-column column))

(defsubst org--no-properties-and-trim (s &optional restricted)
"Remove all text properties from string S and then trim the result.
When RESTRICTED is non-nil, only remove the properties listed
 in `org-rm-props'."
(if restricted (remove-text-properties 0 (length s) org-rm-props s)
  (set-text-properties 0 (length s) nil s))
(org-trim s))

(defsubst org-table--goto-char-and-get-column (char)
  (save-excursion
    (goto-char char)
    (org-table-check-inside-data-field nil t)
    (org-table-current-column)))

(defsubst org-table--goto-char-and-get-line (char)
  (save-excursion
    (goto-char char)
    (org-table-check-inside-data-field nil t)
    (org-table-current-line)))

(defsubst org-table--get-fill-direction (beg end)
  "Helper function for org-table-autofill.
  Use the BEG and END of selection to determine
  the direction of fill."
  (pcase (- beg end) 
    ((pred zerop) #'(lambda (x y) x))
    ((pred plusp) #'-)
    ((pred minusp) #'+)))

(defsubst org-table--get-point-for-line-column (line column)
  (save-excursion
    (org-table--goto-line-column line column)
    (point)))

;; incrementing + prefix arguments are next
(defun org-table-autofill (beg end)
"Copy the value of BEG and paste it into all cells between BEG and END.
This works in any direction: left, right, down right or up left.
With a prefix argument, if the field is a number, a timestamp,
or is either prefixed or suffixed with a number,
the value from BEG will be increment each time its pasted into a cell."
  (interactive (list (mark) (point)))  		
  (let* ((beg-col (org-table--goto-char-and-get-column beg))
   (end-col (org-table--goto-char-and-get-column end))
   (beg-row (org-table--goto-char-and-get-line beg))
   (end-row (org-table--goto-char-and-get-line end))
   (auto-fill-value (org-table-get beg-row beg-col))
   (columns (1+ (abs (- beg-col end-col))))
   (rows (1+ (abs (- beg-row end-row))))
   (left-or-right? (org-table--get-fill-direction beg-col end-col))
   (up-or-down? (org-table--get-fill-direction beg-row end-row)))
    (dotimes (row rows)
      (let ((line (funcall up-or-down? beg-row row)))
     (dotimes (column columns)
       (org-table-put line (funcall left-or-right? beg-col column) auto-fill-value))))
  (org-table-align)
  (goto-char (org-table--get-point-for-line-column end-row end-col))

  (set-mark (org-table--get-point-for-line-column beg-row beg-col))))

(defsubst org-table--count-rows ())

(iter-defun org-table--create-table-iterator (rows cols)
  (let* ((total-cells (* rows cols))
	 (max-col-num (1+ cols))
	 (current-col 1)
	 (current-row 1))
    (dotimes (cell-num total-cells)
      (let* ((new-col (mod cell-num max-col-num)))
	(if (equal new-col 0)
	    (setq current-col 1
		  current-row (1+ current-row))
	  (setq current-col new-col))
	(iter-yield (list (always current-row current-col) current-row current-col))))))

(defun org-table-map-cells (func)
  (goto-char (org-table-begin))
  (let* ((rows (org-table--count-rows))
	 (cols (org-table--count-cols))
	 (table-iterator (org-table--create-table-iterator rows cols)))
    (iter-do (cell-row-col table-iterator)
      (funcall func cell-row-col))))



(defvar-keymap orgtbl-major-mode-map
  :doc "Keymap for `orgtbl-major-mode'."
  "C-c C-w"		 #'org-table-cut-region
  "C-c M-w"		 #'org-table-copy-region
  "C-c C-y"		 #'org-table-paste-rectangle
  "C-c C-="		 #'org-table-autofill
  "C-c -"		 #'org-table-insert-hline
  "C-c C-c"		 #'org-table-align
  "C-c }"		 #'org-table-toggle-coordinate-overlays
  "C-c {"		 #'org-table-toggle-formula-debugger
  "C-m"		 #'org-table-next-row
  "C-c ?"		 #'org-table-field-info
  "C-c +"		 #'org-table-sum
  "C-c ="		 #'org-table-eval-formula
  "C-c '"		 #'org-table-edit-formulas
  "C-c `"		 #'org-table-edit-field
  "C-c *"		 #'org-table-recalculate
  "C-c ^"		 #'org-table-sort-lines
  "M-a"		 #'org-table-beginning-of-field
  "M-e"		 #'org-table-end-of-field
  "M-f"		 #'org-table-next-field
  "M-b"		 #'org-table-previous-field
  "C-x n r"            #'org-table-narrow-to-first-x-rows)


(defvar-keymap orgtbl-major-mode-repeat-map
  :doc "Keymap for `orgtbl-major-mode' when repeat-mode is active."
  :repeat t
  "m"		 #'org-table-next-row
  "f"		 #'org-table-next-field
  "b"		 #'org-table-previous-field)

(defun fac (n)
 (if (< 0 n)
	 (* n (fac (1- n)))
       1))

(fmakunbound 'orgtbl-major-mode-defun)
(defun orgtbl-major-mode-defun ()
  (require 'org)
  (require 'org-table)
  (setq-local truncate-lines t))


(fmakunbound 'orgtbl-major-mode)
(define-derived-mode orgtbl-major-mode nil "orgtbl-major-mode"
  "Major mode for org tables"
  :syntax-table org-mode-syntax-table
  ;;:abbrev-table org-mode-abbrev-table
  :interactive t
  (orgtbl-major-mode-defun))

(defun org-table-narrow-to-first-x-rows (n)
  (interactive "n") 
  (narrow-to-region (org-table-begin) (save-excursion (org-table-goto-line n) (point))))

(provide 'orgtbl-major-mode)
;;; orgtbl-major-mode.el ends here
