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

;; Restricted version of org-mode for file size tables.

;;; Code:

(require 'org)
(require 'org-table)
(require 'org-macs)
(require 'org-compat)
(require 'generator)
(require 'thunk)
(require 'pcase)
(require 'seq)

(defgroup orgtbl-major-mode nil
  "Options for orgtbl-major-mode."
  :tag "orgtbl-major-mode"
  :group 'org)

(defcustom orgtbl-major-mode-save-on-edit-special-finish nil
  "Save tables on edit special finish."
  :type 'boolean
  :group 'orgtbl-major-mode)

(defcustom orgtbl-major-mode-place-cursor-in-first-empty-cell t
  "Place cursor in the first empty cell of the table when
the edit special buffer is opened."
  :type 'boolean
  :group 'orgtbl-major-mode)

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
  "C-x n r"            #'org-table-edit-rows
  "C-x n c"            #'org-table-edit-current-row)


(defvar-keymap orgtbl-major-mode-repeat-map
  :doc "Keymap for `orgtbl-major-mode' when repeat-mode is active."
  :repeat t
  "m"		 #'org-table-next-row
  "f"		 #'org-table-next-field
  "b"		 #'org-table-previous-field)

(defun orgtbl-major-mode-defun ()
  (require 'org)
  (require 'org-table)
  (setq-local truncate-lines 't)
  (setq-local truncate-partial-width-windows 'nil)
  (setq-local org-inhibit-startup 't)
  (setq-local org-table-automatic-realign 'nil))

;; how do we preempt (org-startup-align-all-tables t)
;;;###autoload
(define-derived-mode orgtbl-major-mode org-mode "orgtbl-major-mode"
  "Major mode for org tables."
  :syntax-table org-mode-syntax-table
  ;;:abbrev-table org-mode-abbrev-table
  :interactive t
  (cl-letf (((symbol-function 'org-table-begin)
	     (symbol-function 'point-min))
	    ((symbol-function 'org-table-end)
	     (symbol-function 'point-max)))
    (orgtbl-major-mode-defun)))

(defsubst org--no-properties-and-trim (s &optional restricted)
  "Remove all text properties from string S and then trim the result.
When RESTRICTED is non-nil, only remove the properties listed
 in `org-rm-props'."
  (if restricted (remove-text-properties 0 (length s) org-rm-props s)
    (set-text-properties 0 (length s) nil s))
  (org-trim s))

(defsubst org-current-line-string-no-properties (&optional to-here)
  "Return current line, as a string.
If optional argument TO-HERE is non-nil, return string from
beginning of line up to point."
  (buffer-substring-no-properties (line-beginning-position)
				  (if to-here (point) (line-end-position))))

(defsubst org-table--goto-row-and-get-begin-pos (line)
  (org-table-goto-line line)
  (line-beginning-position))

(defsubst org-table--goto-row-and-get-end-pos (line)
  (org-table-goto-line line)
  (line-end-position))

(defsubst org-table--goto-row-column (line column)
  (org-table-goto-line line)
  (org-table-goto-column column))

(defsubst org-table--goto-char-and-get-column-number (char)
  (save-excursion
    (goto-char char)
    (org-table-check-inside-data-field nil t)
    (org-table-current-column)))

(defsubst org-table--goto-char-and-get-line-number (char)
  (save-excursion
    (goto-char char)
    (org-table-check-inside-data-field nil t)
    (org-table-current-line)))

(defsubst org-table--count-rows ()
  (count-matches org-table-dataline-regexp (org-table-begin) (org-table-end)))

(defsubst org-table--convert-row-string-into-cells (row)
  (string-split (substring row 1 (- (length row) 2)) "|"))

(defsubst org-table--count-cols ()
  (let* ((rows (string-split (string-trim (buffer-substring-no-properties (org-table-begin) (org-table-end))) "\n"))
	 (list-of-list-of-cells (mapcar #'org-table--convert-row-string-into-cells rows)))
    (apply #'max (mapcar #'length list-of-list-of-cells))))

(defsubst org-table--get-point-for-line-column (line column)
  (save-excursion
    (org-table--goto-row-column line column)
    (point)))

(defsubst org-table--get-fill-direction (beg end)
  "Helper function for org-table-autofill.
  Use the BEG and END of selection to determine
  the direction of fill."
  (pcase (- beg end)
    ((pred zerop) #'(lambda (x _) x))
    ((pred plusp) #'-)
    ((pred minusp) #'+)))

(defsubst org-table--contains-hlines ()
  (save-excursion
    (goto-char (org-table-begin))
    (numberp (re-search-forward org-table-hline-regexp (org-table-end) 't))))

(defsubst org-table--get-table-hline ()
  (save-excursion
    (goto-char (org-table-begin))
    (forward-line)
    (org-current-line-string-no-properties)))

(defsubst org-table--get-rows-as-string (beg end)
  (let* ((beg-pos (org-table--goto-row-and-get-begin-pos beg))
	 (end-pos (org-table--goto-row-and-get-end-pos end)))
    (buffer-substring beg-pos end-pos)))

(defsubst org-table--get-line-as-string (line)
  (progn
    (org-table-goto-line line)
    (org-current-line-string-no-properties)))

(defsubst org-table--get-current-table-line-start-point ()
  (save-excursion
    (goto-char (line-beginning-position))
    (search-forward "|")))

(defsubst org-table--get-current-table-line-end-point ()
  (save-excursion
    (goto-char (line-end-position))
    (search-backward "|")))

(defsubst org-table--get-cell-index ()
  (let* ((curr-row (1- (org-table-current-line)))
	 (curr-column (1- (org-table-current-column)))
	 (total-cols (org-table--count-cols)))
    (+ curr-column (* curr-row total-cols))))

(defsubst org-table--get-next-cell-row-column (total-rows
					       total-columns
					       row-column)
  (thunk-let ((row (car row-column))
	      (column (cadr row-column)))
    (cond
     ((equal row-column (list total-rows total-columns))
      row-column)
     ((< column total-columns) (list row (+ column 1)))
     (t (list (+ row 1) 1)))))

(defsubst org-table--get-previous-cell-row-column (total-rows
						   total-columns
						   row-column)
  (thunk-let ((row (car row-column))
	      (column (cadr row-column)))
    (cond
     ((equal row-column (list 1 1))
      (list 1 1))
     ((equal row-column (list total-rows
			      total-columns))
      (list row column))
     ((equal column 1) (list (1- row) total-columns))
     (t (list row (1- column))))))

(defun org-table--goto-cell-index (cell-index)
  (let* ((total-cols (org-table--count-cols))
	 (total-rows (org-table--count-rows))
	 (row-num (floor cell-index total-cols))
	 (col-num (mod cell-index total-cols))
	 (row-col (mapcar #'1+ (list row-num col-num))))
    (apply #'org-table--goto-row-column row-col)))

;; window-start, window-end, window-scroll-functions hook jit-lock-register

;; incrementing + prefix arguments are next
;;;###autoload
(defun org-table-autofill (beg end)
  "Copy the value of BEG and paste it into all cells between BEG and END.
This works in any direction: left, right, down right or up left.
With a prefix argument, if the field is a number, a timestamp,
or is either prefixed or suffixed with a number,
the value from BEG will be increment each time its pasted into a cell."
  (interactive (list (mark) (point)))
  (let* ((beg-col (org-table--goto-char-and-get-column-number beg))
	 (end-col (org-table--goto-char-and-get-column-number end))
	 (beg-row (org-table--goto-char-and-get-line-number beg))
	 (end-row (org-table--goto-char-and-get-line-number end))
	 (auto-fill-value (org-table-get beg-row beg-col))
	 (columns (1+ (abs (- beg-col end-col))))
	 (rows (1+ (abs (- beg-row end-row))))
	 (left-or-right? (org-table--get-fill-direction beg-col end-col))
	 (up-or-down? (org-table--get-fill-direction beg-row end-row)))
    (org-with-undo-amalgamate
      (dotimes (row rows)
	(let ((line (funcall up-or-down? beg-row row)))
	  (dotimes (column columns)
	    (org-table-put line (funcall left-or-right? beg-col column) auto-fill-value))))
      (org-table-align))
    (goto-char (org-table--get-point-for-line-column end-row end-col))
    "most likely need to replace set-mark"
    (set-mark (org-table--get-point-for-line-column beg-row beg-col))))

(iter-defun org-table--create-table-iterator (rows cols &optional start)
  (let* ((total-cells (* rows cols))
	 (current-col 1)
	 (current-row 0)
	 (start-row (or start 1)))
    (dotimes (cell-num total-cells)
      (setq current-col (1+ (mod cell-num cols))
	    current-row (+ (floor cell-num cols) start-row))
      (iter-yield (list current-row current-col)))))

(iter-defun org-table--create-reverse-iterator (rows cols)
  (let* ((total-cells (* rows cols))
	 (current-col cols)
	 (current-row rows))
    (dotimes (cell-num total-cells)
      (setq current-col (- cols (mod cell-num cols))
	    current-row (- rows (floor cell-num cols)))
      (iter-yield (list current-row current-col)))))

(defun org-table--map-cells (func)
  (goto-char (org-table-begin))
  (let* ((rows (org-table--count-rows))
	 (cols (org-table--count-cols))
	 (table-iterator (org-table--create-table-iterator rows cols)))
    (cl-letf (((symbol-function 'org-table-end) (lambda () (point-max))))
      (iter-do (row-col table-iterator)
	(funcall func row-col)))
    (org-table-align)))

(cl-defun org-table--map-selected-rows (func (start-row end-row) &optional (align 't))
  (goto-char (org-table-begin))
  (let* ((rows (1+ (- end-row start-row)))
	 (cols (org-table--count-cols))
	 (rows-iterator (org-table--create-table-iterator rows cols start-row)))
    (cl-letf (((symbol-function 'org-table-end) (lambda () (point-max))))
      (combine-change-calls (org-table-begin) (org-table-end)
	(iter-do (row-col rows-iterator)
	  (funcall func row-col)))
      (and align (org-table-align)))))

(defun org-table-get-rows-as-list (start-row end-row)
  (let ((rows)
	(cols (org-table--count-cols)))
    (org-table--map-selected-rows (pcase-lambda (`(,row ,col))
				    (push (org-table-get row col) rows))
				  (list start-row end-row) 'nil)
    (seq-split (reverse rows) cols)))

(defun org-table--replace-selected-rows-helper (new-values previous-values start-row)
  (if previous-values
      (pcase-lambda (`(,row ,col)) (org-table-put row col (nth (1- col) (nth (- row start-row) new-values))))
    (pcase-lambda (`(,row ,col))
      (let* ((previous-cell-value (nth (1- col) (nth (- row start-row) previous-values)))
	     (new-cell-value (nth (1- col) (nth (- row start-row) new-values))))
	(unless (string-equal new-cell-value previous-cell-value)
	  (org-table-put row col new-cell-value))))))

(cl-defun org-table-replace-selected-rows ((start-row end-row) new-values &optional previous-values)
  (org-table--map-selected-rows (org-table--replace-selected-rows-helper new-values previous-values start-row) (list start-row end-row)))

(cl-defun org-table-map-cells (func)
  (org-table--map-cells
   (pcase-lambda (`(,row ,col))
     (org-table-put row col
		    (funcall func (org-table-get row col))))))

(cl-defun org-table-map-selected-rows (func (start-row end-row))
  (org-table--map-selected-rows
   (pcase-lambda (`(,row ,col))
     (org-table-put row col
		    (funcall func (org-table-get row col))))
   (list start-row end-row)))

(defalias 'org-table--remove-hlines-from-list
  (apply-partially #'seq-remove
		   (apply-partially #'equal 'hline)))

(cl-defun org-table-replace-region (start-row end-row new-rows &optional (align t))
  (let* ((org-table-automatic-realign nil)
	 (start (progn (org-table-goto-line start-row)
		       (line-beginning-position)))
	 (end (if (equal start-row end-row)
		  (line-end-position)
		(org-table--goto-row-and-get-end-pos
		 end-row))))
    (progn
      (delete-region start end)
      (insert new-rows)
      (and align (org-table-align)))))

(defun org-table-goto-first-empty-cell-in-table ()
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not at a table"))
  (let* ((table (org-table--remove-hlines-from-list
		 (org-table-to-lisp)))
	 (rows (length table))
	 (cols (length (car table)))
	 (iter (org-table--create-table-iterator rows cols)))
    (cl-labels ((cell-is-not-empty ((current-row current-col))
		  (thread-last table
			       (nth (1- current-row))
			       (nth (1- current-col))
			       (funcall (lambda (cell-val)
					  (length> cell-val 0)))))
		(get-first-empty-cell (iterator)
		  (let ((next-corr (condition-case end
				       (iter-next iterator)
				     (iter-end-of-sequence
				      :end))))
		    (cond
		     ((equal :end next-corr) (list rows cols))
		     ((cell-is-not-empty next-corr)
		      (get-first-empty-cell iterator))
		     (t next-corr)))))
      (thread-last iter
		   get-first-empty-cell
		   (apply #'org-table--goto-row-column)))))

(cl-defun org-table--finish-edit-rows (start-row
				       end-row
				       added-header-to-selection-p
				       original-buffer
				       original-point
				       &optional
				       (save-on-finish
					orgtbl-major-mode-save-on-edit-special-finish))
  (interactive)
  (progn
    (goto-char (point-min))
    (org-table-begin)
    (when added-header-to-selection-p
      (org-table-goto-line 2)))
  (let* ((new-rows (buffer-substring-no-properties
		    (line-beginning-position)
		    (org-table-end))))
    (switch-to-buffer original-buffer)
    (kill-buffer "*Org Table Edit Field*")
    (org-table-replace-region
     start-row end-row (org-trim new-rows))
    (goto-char original-point)
    (when save-on-finish
      (save-buffer original-buffer))))

(defun org-table--cancel-edit-rows (original-buffer original-point)
  (switch-to-buffer original-buffer)
  (kill-buffer "*Org Table Edit Field*")
  (goto-char original-point))

;;;###autoload
(cl-defun org-table-edit-rows (beg end &optional with-header
				   (place-index-in-first-empty-cell
				    orgtbl-major-mode-place-cursor-in-first-empty-cell))
  (interactive (list (region-beginning) (region-end) 't))
  (let* ((original-point (point))
	 (start-row (org-table--goto-char-and-get-line-number beg))
	 (end-row (org-table--goto-char-and-get-line-number end))
	 (added-header-to-selection-p (and with-header (> start-row 1)))
	 (body-rows (if (equal start-row end-row)
			(org-table--get-line-as-string start-row)
		      (org-table--get-rows-as-string start-row end-row)))
	 (hline (if (and added-header-to-selection-p
			 (org-table--contains-hlines))
		    (concat (org-table--get-table-hline) "\n")
		  ""))
	 (rows (if added-header-to-selection-p
		   (concat (org-table--get-line-as-string 1)
			   "\n" hline body-rows)
		 body-rows))
	 (original-buffer (current-buffer)))
    (pop-to-buffer "*Org Table Edit Field*")
    (erase-buffer)
    (insert rows)
    (orgtbl-major-mode)
    (org-table-begin)
    (org-table-align)
    (and place-index-in-first-empty-cell
	 (org-table-goto-first-empty-cell-in-table))
    (keymap-local-set "C-c '"
		      (lambda () (interactive)
			(funcall #'org-table--finish-edit-rows
				 start-row
				 end-row
				 added-header-to-selection-p
				 original-buffer
				 original-point)))
    (keymap-local-set "C-c C-k" (lambda () (interactive)
				  (funcall
				   #'org-table--cancel-edit-rows
				   original-buffer
				   original-point)))
    (setq header-line-format
	  " Edit, then exit with C-c ' or abort with C-c C-k")
    (message "Edit Rows and finish with C-c '")))

;;;###autoload
(cl-defun org-table-edit-current-row (&optional with-header
						(place-index-in-first-empty-cell
						 orgtbl-major-mode-place-cursor-in-first-empty-cell))
  (interactive (list 't))
  (let* ((line-start (org-table--get-current-table-line-start-point))
	 (line-end (org-table--get-current-table-line-end-point)))
    (org-table-edit-rows
     line-start
     line-end with-header
     place-index-in-first-empty-cell)))

(defun org-table-narrow-to-first-x-rows (n)
  (interactive "n")
  (narrow-to-region (org-table-begin) (save-excursion (org-table-goto-line n) (point))))

(provide 'orgtbl-major-mode)
;;; orgtbl-major-mode.el ends here
