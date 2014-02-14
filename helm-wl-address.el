;;; helm-wl-address.el --- Helm source for wanderlust address

;; Copyright (C) 2014  TAKAGI Kentaro <kentaro0910_at_gmail.com>

;; Author: TAKAGI Kentaro <kentaro0910_at_gmail.com>
;; Package-Requires: ((helm "1.5.8"))
;; Keywords: mail

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This packages needs helm and helm-migemo.  Please install.
;; Please write the following code to your "~/.emacs" and
;; type tab key in wl-draft-mode.
;;
;; (add-to-list 'load-path "/path/to/here")
;; (require 'helm-wl-address)
;;
;; If you want to disable it, please type "M-x helm-wl-address-deactivate-tab".
;; Conversely, you can turn it on by "M-x helm-wl-address-activate-tab".

;;; For Japanese User:

;; If you add following code, you can use migemo match in helm-wl-address.
;;
;; (require 'helm-migemo)
;; (setq helm-use-migemo t)
;;

;;; Code:

(require 'helm)

(defvar helm-wl-address-pattern "")
(defvar helm-wl-address-pattern-start 1)
(defvar helm-wl-address-pattern-end 1)

(defun helm-wl-address-get-pattern ()
  (let ((end (point))
        (start (save-excursion
                 (skip-chars-backward "^:,>\n")
                 (skip-chars-forward " \t")
                 (point))))
    (setq
     helm-wl-address-pattern-start start
     helm-wl-address-pattern-end end
     helm-wl-address-pattern (buffer-substring start end)
     )))


(defun helm-wl-address-candidates ()
  (cl-loop for i in wl-address-list
           collect (list (mapconcat 'identity i ", ")
                         (concat (caddr i) " <" (car i) ">"))))

(defvar helm-wl-address-source
  '((name . "wl-address")
    (candidates . helm-wl-address-candidates)
    (migemo)
    (action . (("insert" .
                (lambda (candidates)
                  (delete-region helm-wl-address-pattern-start helm-wl-address-pattern-end)
                  (insert (mapconcat 'identity
                              (cl-loop for i in (helm-marked-candidates)
                                       collect (car i)) ", "))))))))

(defvar helm-wl-address-header-list '("to" "from" "cc" "bcc"))

(defun helm-wl-address-header-p ()
  (and
   (< (point)
      (save-excursion
        (goto-char (point-min))
        (search-forward (concat "\n" mail-header-separator "\n") nil t)
        (point)))
   (save-excursion
     (beginning-of-line)
     (while (and (looking-at "^[ \t]")
                 (not (= (point) (point-min))))
       (forward-list -1))
     (looking-at (concat (regexp-opt helm-wl-address-header-list t) ":")))))

;;;###autoload
(defun helm-wl-address ()
  "Helm for wanderlust address."
  (interactive)
  (helm :sources '(helm-wl-address-source)
        :buffer "*helm wl address*"
        :input (helm-wl-address-get-pattern)))

;;; Use helm-wl-address with tab key in wl-draft-mode.
(defadvice wl-complete-field-body-or-tab (around for-helm-wl-address activate)
  (if (helm-wl-address-header-p)
      (helm-wl-address)
    ad-do-it))

;;;###autoload
(defun helm-wl-address-activate-tab ()
  "Activate the advice of  wl-complete-field-body-or-tab."
  (interactive)
  (ad-activate 'wl-complete-field-body-or-tab))

;;;###autoload
(defun helm-wl-address-deactivate-tab ()
  "Deactivate the advice of  wl-complete-field-body-or-tab."
  (interactive)
  (ad-deactivate 'wl-complete-field-body-or-tab))

(provide 'helm-wl-address)
;;; helm-wl-address.el ends here
