;;; modern-icons-helm.el --- Modern icons for Helm -*- lexical-binding: t -*-

;; Copyright (C) 2025 Quang Trung Ta

;; Author: Quang Trung Ta <taquangtrungvn@gmail.com>
;; Version: 0.1.0
;; Created: May 27, 2025
;; Homepage: https://github.com/emacs-modern-icons/modern-icons-helm.el
;; Package-Requires: ((emacs "28.1") (modern-icons "0.1") (helm "3.0"))
;; Keywords: lisp, icons, vscode-icons, helm

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

;; To use this package, simply install and add this to your init.el
;;
;; (require 'modern-icons-helm)
;; (modern-icons-helm-enable)

;; Acknowledgement:
;;
;; This package is inspired by: helm-icons: <https://github.com/yyoncho/helm-icons>

;;; Code:

(require 'dash)
(require 'modern-icons)
(require 'helm)
(require 'helm-locate)
(require 'helm-files)
(require 'helm-grep)
(require 'helm-imenu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; General configuration for Helm

(defun modern-icons-helm-file-name-icon (file-name)
  "Get icon by matching exact FILE-NAME."
  (when-let* ((icon (modern-icons-icon-for-file-name file-name)))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-file-ext-icon (file-name)
  "Get icon by matching the extension of FILE-NAME."
  (when-let* ((icon (modern-icons-icon-for-file-ext file-name)))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-dir-icon (dir-name)
  "Get icon by matching DIR-NAME."
  (when-let* ((icon (or (modern-icons-icon-for-dir dir-name)
                        (modern-icons-default-dir-icon))))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-buffer-icon (buffer-name)
  "Get icon for a BUFFER-NAME."
  (let* ((icon (or (modern-icons-icon-for-buffer buffer-name)
                   (modern-icons-icon-for-file buffer-name))))
    (and icon (concat (propertize " " 'display icon) " "))))

(defun modern-icons-helm-major-mode-icon (mode)
  "Get icon for the major mode MODE."
  (when-let* ((icon (modern-icons-icon-for-major-mode mode)))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-persp-icon (persp-name)
  "Get icon by matching PERSP-NAME."
  (when-let* ((icon (or (modern-icons-icon-for-persp persp-name)
                        (modern-icons-default-file-icon))))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-prefix-icon (prefix)
  "Get icon for a prefix."
  (when-let* ((icon (cond ((equal prefix "[?]")
                           (modern-icons-create-icon "symbol-icons" "unknown.svg"))
                          ((equal prefix "[+]")
                           (modern-icons-create-icon "symbol-icons" "new.svg"))
                          (t nil))))
    (concat (propertize " " 'display icon) " ")))

(defun modern-icons-helm-add-icons (candidates source)
  "Add icon to a buffer source or a file source.
CANDIDATES is the list of Helm candidates."
  (let ((source-name (cdr (assoc 'name source)))
        (source-candidates (cdr (assoc 'candidates source))))
    (-map
     (-lambda (candidate)
       (let* ((display (if (listp candidate) (car candidate) candidate))
              (candidate (if (listp candidate) (cdr candidate) candidate))
              (buffer (cond ((bufferp candidate) candidate)
                            ((stringp candidate) (get-buffer candidate))
                            (t nil)))
              (file-name nil)
              (icon
               (progn
                 (cond ((equal source-name "Git branches")
                        (modern-icons-helm-file-name-icon ".git"))
                       ((equal source-name "find-library")
                        (modern-icons-helm-major-mode-icon "emacs-lisp-mode"))
                       ((member source-name '("+workspace/switch-to"
                                              "persp-frame-switch"))
                        (modern-icons-helm-persp-icon candidate))
                       ((equal source-name "Create buffer")
                        (or (modern-icons-helm-buffer-icon display)
                            (modern-icons-helm-major-mode-icon 'fundamental-mode)))
                       ((equal source-candidates '("dummy"))
                        (if (string-prefix-p " " display)
                            (when (equal (get-text-property 0 'display display) "[?]")
                              (setq display (substring display 1))
                              (modern-icons-helm-prefix-icon "[?]"))
                          (modern-icons-helm-prefix-icon "[?]")))
                       (buffer
                        (with-current-buffer buffer
                          (setq buff-name (buffer-name)
                                file-name (buffer-file-name))
                          (or (and file-name
                                   (not (file-directory-p file-name))
                                   (modern-icons-helm-file-name-icon file-name))
                              (modern-icons-helm-buffer-icon buff-name)
                              (and (not (equal major-mode 'fundamental-mode))
                                   (modern-icons-helm-major-mode-icon major-mode))
                              (and file-name
                                   (or (and (file-directory-p file-name)
                                            (modern-icons-helm-dir-icon file-name))
                                       (modern-icons-helm-file-ext-icon file-name)))
                              (and (or (char-equal ?* (aref buff-name 0))
                                       (char-equal ?\s (aref buff-name 0)))
                                   (modern-icons-helm-major-mode-icon 'temporary-mode))
                              (modern-icons-helm-major-mode-icon 'fundamental-mode))))
                       ((stringp candidate)
                        (setq file-name candidate)
                        ;; Remove quotation in quoted file-name names if any
                        (when (and (string-prefix-p "'" file-name)
                                   (string-suffix-p "'" file-name)
                                   (> (length file-name) 1))
                          (setq file-name (substring file-name 1 (1- (length file-name)))))
                        (or (and (file-directory-p file-name)
                                 (modern-icons-helm-dir-icon file-name))
                            (modern-icons-helm-file-name-icon file-name)
                            (modern-icons-helm-file-ext-icon file-name)
                            (modern-icons-helm-major-mode-icon 'fundamental-mode)))
                       (t (modern-icons-helm-major-mode-icon 'fundamental-mode))))))
         (cons (concat icon display) candidate)))
     candidates)))

(defun modern-icons-helm-add-transformer (func source)
  "Add func to `filtered-candidate-transformer' slot of helm-source SOURCE."
  (setf (alist-get 'filtered-candidate-transformer source)
        (-uniq (append
                (-let [value (alist-get 'filtered-candidate-transformer source)]
                  (if (seqp value) value (list value)))
                (list func)))))

(defun modern-icons-helm-advisor (func name class &rest args)
  "Advice function for `helm-source' to display icons.
The advised function is `helm-make-source'."
  (let ((result (apply func name class args)))
    ;; (message "DEBUG modern-icons-helm--make: class: %s, name: %s" class name)
    (cond ((member class '(helm-fasd-source
                           helm-ls-git-source
                           helm-ls-git-status-source
                           helm-ls-git-untracked-ignored-source
                           helm-ls-git-untracked-source
                           helm-recentf-source
                           helm-source-buffers
                           helm-source-dummy
                           helm-source-ffiles
                           helm-source-findutils
                           helm-source-locate
                           helm-source-projectile-buffer))
           (modern-icons-helm-add-transformer #'modern-icons-helm-add-icons result))
          ((-any? (lambda (source-name) (s-match source-name name))
                  '("Buffers in hg project"
                    "Create buffer"
                    "Elisp libraries"
                    "Find"
                    "Hg files list"
                    "Hg status"
                    "Last killed files"
                    "Locate"
                    "Projectile directories"
                    "Projectile files in current Dired buffer"
                    "Projectile files"
                    "Projectile projects"
                    "Projectile recent files"
                    "Projectile"
                    "Read File Name"
                    "Recent files and dirs"
                    "Recentf"
                    "Switch to project"
                    "TeX-master-file-ask"
                    "byte-compile-file"
                    "byte-recompile-file"
                    "dired-create-directory"
                    "dired-do-copy"
                    "dired-do-rename"
                    "ediff-buffers"
                    "ediff-files"
                    "helm-find"
                    "helm-grep-ag-directory"
                    "kill-buffer"
                    "persp-add-buffer"
                    "persp-remove-buffer"
                    "persp-frame-switch"
                    "project-find-file"
                    "rename-current-buffer"
                    "rename-current-file"
                    "save-current-file"
                    "switch-to-buffer"
                    "+workspace/switch-to"))
           (modern-icons-helm-add-transformer #'modern-icons-helm-add-icons result)))
    result))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Specific configuration for `helm-files'

(defun modern-icons-helm-files-advisor (func disp fname &optional new-file &rest args)
  "Advise `helm-files' to display icons for new files.
The advised function is `helm-ff-prefix-filename'."
  (let* ((new-file-icon (cond ((null new-file) nil)
                              ((or (string-match "/\\'" disp)
                                   (equal helm-buffer "*helm-mode-dired-create-directory*"))
                               (or (modern-icons-icon-for-dir disp)
                                   (modern-icons-default-dir-icon)))
                              (t (or (modern-icons-icon-for-file disp)
                                     (modern-icons-default-file-icon))))))
    (if new-file-icon
        (concat (modern-icons-helm-prefix-icon "[+]")
                (concat (propertize " " 'display new-file-icon) " ")
                disp)
      disp)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Specific configuration for `helm-grep'

(defun modern-icons-helm-grep-advisor (func &rest args)
  "Advise `helm-grep' to display icons.
The advised function is `helm-grep--filter-candidate-1'."
  (let* ((res (apply func args))
         (display (if (consp res) (car res) res))
         (candidate (if (consp res) (cdr res) res)))
    (if-let* ((components (split-string display ":"))
              (_ (length> components 2))
              (file (cl-first components))
              (icon (propertize " " 'display (or (modern-icons-icon-for-file file)
                                                 (modern-icons-default-file-icon))))
              (display (concat icon
                               (propertize " " 'display '(space :width 0.5))
                               display)))
        (cons display candidate)
      res)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Specific configuration for `helm-imenu'

(defun modern-icons-helm-imenu-advisor (_func type &rest _args)
  "Advise `helm-imenu' to display icons.
The advised function is `helm-imenu-icon-for-type'."
  (modern-icons-icon-for-code-item type))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Public functions

;;;###autoload
(defun modern-icons-helm-enable ()
  "Enable `modern-icons-helm'."
  (interactive)
  ;; Advise `'helm-make-source' to add icon transformer for almost all Helm packages.
  (advice-add 'helm-make-source :around #'modern-icons-helm-advisor)

  ;; Some packages need to add icon transformer manually since
  (modern-icons-helm-add-transformer #'modern-icons-helm-add-icons helm-source-buffer-not-found)
  (modern-icons-helm-add-transformer #'modern-icons-helm-add-icons helm-source-locate)

  ;; Specific configuration to other packages

  ;; helm-files
  (advice-add 'helm-ff-prefix-filename :around #'modern-icons-helm-files-advisor)
  ;; helm-grep
  (advice-add 'helm-grep--filter-candidate-1 :around #'modern-icons-helm-grep-advisor)
  ;; helm-imenu
  (advice-add 'helm-imenu-icon-for-type :around #'modern-icons-helm-imenu-advisor)

  (when (called-interactively-p 'any)
    (message "Modern-icons-helm is enabled!")))

(provide 'modern-icons-helm)
;;; modern-icons-helm.el ends here
