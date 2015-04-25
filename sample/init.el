(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(package-refresh-contents)
(unless (package-installed-p 'wanderlust)
  (package-install 'wanderlust))
(unless (package-installed-p 'helm-migemo)
  (package-install 'helm-migemo))

(setq wl-init-file (concat user-emacs-directory "dot.wl"))
(setq wl-folders-file (concat user-emacs-directory "dot.folders"))
(setq wl-address-file (concat user-emacs-directory "dot.addresses"))
; (setq wl-plugged nil)

(setq elmo-localdir-folder-path (concat user-emacs-directory "localmail"))
(setq elmo-msgdb-directory (concat user-emacs-directory "elmo"))

(add-to-list 'load-path (file-name-directory (concat user-emacs-directory  "../")))
(require 'helm-wl-address)
