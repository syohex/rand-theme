;;; rand-theme.el --- Random Emacs theme at start-up!
;;
;; Filename: rand-theme.el
;; Description:
;; Author: Daniel Gopar
;; Maintainer: Daniel Gopar
;; Created: Tue Oct 20 22:21:57 2015 (-0700)
;; Version: 0.1
;; Package-Requires: ()
;; URL: https://github.com/gopar/rand-theme
;; Keywords:
;; Compatibility:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'cl)

(defcustom rand-theme-unwanted nil
  "List of themes that you *don't* want to randomly select."
  :type 'sexp
  :group 'theme-list)

(defcustom rand-theme-wanted nil
  "List of themes that you *only* want to randomly select.
If this is non-nil then it will have a higher precedence than `rand-theme-unwanted'."
  :type 'sexp
  :group 'theme-list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions
(defun rand-theme--get-theme-list ()
  "Return a list of themes to use"
  (if (null (or rand-theme-unwanted rand-theme-wanted))
      (error "Neither `rand-theme-unwanted' nor `rand-theme-wanted' have been set."))
  (let ((available-themes (custom-available-themes)) (theme nil))
    (if (null rand-theme-wanted)
        ;; Filter out unwanted themes
        (mapc '(lambda (unwanted) (setq available-themes (remove unwanted available-themes))) rand-theme-unwanted)
      ;; No need to filter since we already have a list we want to use
      (setq available-themes rand-theme-wanted))
    ;; return themes to use
    available-themes))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactive functions

(defun rand-theme ()
  "Randomly pick a theme from `rand-theme-unwanted' or if non-nil from `rand-theme-wanted'.
Will raise error if both of these variables are nil."
  (interactive)
  (let ((available-themes (rand-theme--get-theme-list))
        (theme nil))
    ;; Randomly choose a theme
    (setq theme (nth (random (length available-themes)) available-themes))
    ;; Disable ALL themes
    (mapcar 'disable-theme custom-enabled-themes)
    (load-theme theme t)))

(defun rand-theme-iterate ()
  "Iterate through the list of themes.
In case you want to go incremental."
  (interactive)
  (let ((available-themes (rand-theme--get-theme-list))
        (curr-pos nil)
        ;; current enabled theme. Only get first one. Ignore others
        (curr-theme (nth 0 (mapcar 'symbol-name custom-enabled-themes))))
    ;; Get the next theme in line
    (setq curr-pos (1+ (cl-position (intern curr-theme) available-themes)))
    (if (>= curr-pos (length available-themes))
        (setq curr-pos 0))
    (setq curr-theme (nth curr-pos available-themes))
    ;; Disable ALL themes
    (mapcar 'disable-theme custom-enabled-themes)
    (load-theme curr-theme)
    (message "Loaded Theme: %s" (symbol-name curr-theme))
    ))

(provide 'rand-theme)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; rand-theme.el ends here
