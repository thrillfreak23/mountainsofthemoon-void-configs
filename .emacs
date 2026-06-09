;; -*- lexical-binding: t; -*-

;; always open emacs maximized
;; Start every new frame maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; =====================================================
;; PACKAGES
;; =====================================================

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(defvar my-packages
  '(org org-appear org-superstar
    avy ace-window use-package))

(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

(eval-when-compile
  (require 'use-package))

;; =====================================================
;; UI BASICS
;; =====================================================

(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; =====================================================
;; ORG MODE
;; =====================================================

;; minimalist org-mode ---------------------------------
(require 'org)

;; core behavior
(setq org-hide-leading-stars t
      org-startup-indented t)

;; NO emphasis hiding (so /italics/ stay visible literally)
(setq org-hide-emphasis-markers nil)

;; NO hiding links: [[link]]
(setq org-link-descriptive nil)

;; =====================================================
;; AVY (your M-j jump tool)
;; =====================================================

(global-set-key (kbd "M-j") 'avy-goto-char-timer)

;; ====================================================
;; atomic-chrome
;; ====================================================
(require 'atomic-chrome)
(atomic-chrome-start-server)


;; =====================================================
;; WINDOW SWITCHING (M-i)
;; =====================================================
;; Simple + reliable replacement for Winum-style workflow

(use-package ace-window
  :ensure t
  :bind (("M-i" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; =====================================================
;; ABBREVIATIONS (AAA → â etc.)
;; =====================================================

(defvar my-abbrev-alist
  '(("AAA" . "â")
    ("NGG" . "ŋ")
    ("GLL" . "ʔ")
    ("LHH" . "ɬ")
    ("UHH" . "ʌ")
    ("SHH" . "ʃ")
    ("NYY" . "ɲ")
    ("ZHH" . "ʒ")
    ("THH" . "þ")
    ("DHH" . "ð")
    ("EEE" . "ê")
    ("III" . "î")
    ("OOO" . "ô")
    ("UUU" . "û")))

(defun my/expand-abbrev ()
  (let* ((end (point))
         (start (max (point-min) (- end 3)))
         (typed (buffer-substring-no-properties start end))
         (match (assoc typed my-abbrev-alist)))
    (when match
      (delete-region start end)
      (insert (cdr match)))))

(add-hook 'post-self-insert-hook #'my/expand-abbrev)

;; =====================================================
;; MODERN COMPLETION STACK (SAFE)
;; =====================================================

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

(use-package consult
  :ensure t)

;; Orderless (you already use this idea, this is the stable version)
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides nil))

(global-set-key (kbd "C-s") 'consult-line)
(global-set-key (kbd "C-x b") 'consult-buffer)

;; =====================================================
;; LITTLE BITS
;; =====================================================

;; this provides margins
(use-package visual-fill-column
  :ensure t
  :hook (org-mode . (lambda ()
                      (setq visual-fill-column-width 120
                            visual-fill-column-center-text t)
                      (visual-fill-column-mode 1)
                      (visual-line-mode 1))))

(defun my/open-config ()
  (interactive)
  (find-file "~/.emacs"))

(defun my/open-tokipona ()
  (interactive)
  (find-file "/home/rachel/tokipona/nimi_pi_toki_pona.txt"))


(defun my/open-diary ()
  (interactive)
  (find-file "~/notes/diary.txt"))

(defun my/open-raggo ()
  (interactive)
  (find-file "~/notes/raggo.org"))

(defun my/open-jlex ()
  (interactive)
  (find-file "~/notes/jlex.org"))

(defun my/open-nulin ()
  (interactive)
  (find-file "~/notes/nulin.org"))

(defun my/open-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun my/open-jtables ()
  (interactive)
  (find-file "~/notes/jtables.org"))

(global-set-key (kbd "C-c e") #'my/open-config)
(global-set-key (kbd "C-c r") #'my/open-raggo)
(global-set-key (kbd "C-c j l") #'my/open-jlex)
(global-set-key (kbd "C-c n l") #'my/open-nulin)
(global-set-key (kbd "C-c s") #'my/open-scratch)
(global-set-key (kbd "C-c j t") #'my/open-jtables)
(global-set-key (kbd "C-c d") #'my/open-diary)
(global-set-key (kbd "C-c t p") #'my/open-tokipona)

;; insert lexicon entry template
(defun my/insert-lexicon-template ()
  "Insert lexicon template for org notes."
  (interactive)
  (insert
   "** part of speech: \n"
   "** definition: \n"
   "** valency: \n"
   "** examples and usage: \n"
   "** note: \n")
  (previous-line 4)
  (end-of-line))

(global-set-key (kbd "C-c l t") #'my/insert-lexicon-template)


;; global editing behavior
(setq transient-mark-mode t)
(delete-selection-mode 1)

;; in text mode soft wrap
(add-hook 'text-mode-hook 'visual-line-mode)

;; =====================================================
;; MANUAL PERSISTENT SCRATCH (clean version)
;; =====================================================

(defvar my/scratch-file "~/.emacs.d/persistent-scratch.txt")

(defun my/load-scratch ()
  (with-current-buffer (get-buffer-create "*scratch*")
    (lisp-interaction-mode)
    (erase-buffer)
    (when (file-exists-p my/scratch-file)
      (insert-file-contents my/scratch-file))
    (goto-char (point-max))))

(defun my/save-scratch ()
  (interactive)
  (with-current-buffer "*scratch*"
    (write-region (point-min) (point-max) my/scratch-file)
    (message "Scratch saved.")))

(add-hook 'emacs-startup-hook #'my/load-scratch)

(setq initial-scratch-message nil)

(global-set-key (kbd "C-c S") #'my/save-scratch)

;; ====== END SCRATCH SECTION =============================

;; ====== BEGIN EVIL-MODE SECTION =====================================
(setq evil-want-integration t)
(setq evil-want-keybinding nil)

(require 'evil)
(evil-mode 0)

;; to make evil respect emacs soft folds and org-mode softwrap etc etc
(with-eval-after-load 'evil
  (define-key evil-motion-state-map (kbd "j") #'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "k") #'evil-previous-visual-line))
;; ====== END EVIL-MODE SECTION =======================================

(defun insert-current-date ()
  "Insert the current date at point."
  (interactive)
  (insert (shell-command-to-string "date +'%F'")))

(global-set-key (kbd "<f5>") 'insert-current-date)

(defun insert-current-time ()
  "Insert the current time at point."
  (interactive)
  (insert (shell-command-to-string "date +'%R'")))

(global-set-key (kbd "<f6>") 'insert-current-time)

(setq-default default-directory "~/notes/")

;; YOW!!!
(defun yow ()
  "Display a random Zippy-ism from a Null-separated yow.lines file."
  (interactive)
  (let ((file "/home/rachel/.emacs.d/yow.lines"))
    (if (file-exists-p file)
        (with-temp-buffer
          (insert-file-contents file)
          (let* ((contents (buffer-string))
                 ;; Split by the null character (^@)
                 (all-parts (split-string contents "\000" t))
                 ;; Remove the first part (the header/comments)
                 (quotes (cdr all-parts))
                 (chosen (nth (random (length quotes)) quotes)))
            (if chosen
                (message "%s" (string-trim chosen))
              (message "Zippy is confused (no quotes found)."))))
      (error "Cannot find %s" file))))

;; markdown-mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))

;; enable nicer features
(setq markdown-command "pandoc") ;; or "multimarkdown"
(setq markdown-fontify-code-blocks-natively t)
(setq markdown-enable-math t)
(setq markdown-enable-wiki-links t)

;; markdown keybindings
(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-map (kbd "C-c C-p") 'markdown-preview))

;; Prefer side-by-side (vertical) splits
(setq split-height-threshold nil)
(setq split-width-threshold 0)

(setq markdown-indent-on-enter 'indent-and-new-item)

(add-hook 'text-mode-hook 'turn-on-auto-fill)

;;; ===== C-o and M-o open newlines like vi =====
(defun open-line-below ()
  "Open a new line below the current one and move there."
  (interactive)
  (end-of-line)
  (newline-and-indent))
;;
(defun open-line-above ()
  "Open a new line above the current one and move there."
  (interactive)
  (beginning-of-line)
  (open-line 1)
  (indent-according-to-mode))
;;
;; Bind them to your preferred keys
(global-set-key (kbd "C-o") 'open-line-below)
(global-set-key (kbd "M-o") 'open-line-above)
;;; ===== end C-o and M-o open lines like vi =====

;;; =============== duplicate line like yyp in vi
(defun duplicate-line-down ()
  "Duplicate the current line to the line below, like yyp in Vim."
  (interactive)
  (let ((column (current-column)))
    (if (fboundp 'duplicate-line)
        (duplicate-line) ;; Use built-in if on Emacs 29+
      ;; Fallback for older versions
      (save-excursion
        (let ((line-text (buffer-substring (line-beginning-position) (line-end-position))))
          (end-of-line)
          (insert "\n" line-text))))
    (next-line)
    (move-to-column column)))
;;
;; Bind it (C-d is a popular choice for "Duplicate")
(global-set-key (kbd "C-c d") 'duplicate-line-down)

;;;;; ==================== ATOMIC CHROME =====================
;; (use-package atomic-chrome
;;   :defer t
;;   :init
;;   (defvar km-atomic-chrome-first-frame-changed nil
;;     "Non-nil if a frame focus change occurred after Emacs started.
;; Tracks whether to defer `atomic-chrome' server startup until the first focus
;; change.")
;;   (defun km-atomic-chrome-run-server-after-focus-change (&rest _)
;;     "Start Atomic Chrome server upon graphical frame focus change.

;; For GUI sessions:
;; - The server is started only on the second focus change event (the first one
;;   is triggered immediately after Emacs starts).
;; - After starting the server, this function removes itself from
;;   `after-focus-change-function' to avoid further overhead.

;; In terminal (`tty') environments, it disables itself immediately since focus
;; changes are not applicable."
;;     (let ((frame (selected-frame)))
;;       (if (tty-top-frame frame)
;;           (remove-function after-focus-change-function
;;                            'km-atomic-chrome-run-server-after-focus-change)
;;         (when (frame-parameter frame 'last-focus-update)
;;           (if (not km-atomic-chrome-first-frame-changed)
;;               (setq km-atomic-chrome-first-frame-changed t)
;;             (remove-function after-focus-change-function
;;                              'km-atomic-chrome-run-server-after-focus-change)
;;             (require 'atomic-chrome)
;;             (when (fboundp 'atomic-chrome-start-server)
;;               (atomic-chrome-start-server)))))))
;;   (add-function :after after-focus-change-function
;;                 'km-atomic-chrome-run-server-after-focus-change)
;;   :straight (atomic-chrome
;;              :type git
;;              :flavor nil
;;              :host github
;;              :repo "KarimAziev/atomic-chrome")
;;   :defines atomic-chrome-create-file-strategy
;;   :config
;;   (setq-default atomic-chrome-buffer-open-style 'frame)
;;   (setq-default atomic-chrome-auto-remove-file t)
;;   (setq-default atomic-chrome-url-major-mode-alist
;;                 '(("github.com" . gfm-mode)
;;                   ("us-east-2.console.aws.amazon.com" . yaml-ts-mode)
;;                   ("ramdajs.com" . js-ts-mode)
;;                   ("gitlab.com" . gfm-mode)
;;                   ("leetcode.com" . typescript-ts-mode)
;;                   ("typescriptlang.org" . typescript-ts-mode)
;;                   ("jsfiddle.net" . js-ts-mode)
;;                   ("w3schools.com" . js-ts-mode)))
;;   (add-to-list 'atomic-chrome-create-file-strategy
;;                '("~/repos/ts-scratch/src/" :extension
;;                  ("js" "ts" "tsx" "jsx" "cjs" "mjs")))
;;   (add-to-list 'atomic-chrome-create-file-strategy
;;                '("~/repos/python-scratch" :extension ("py"))))
;;;;;; END atomic chrome =========================================






;;; =============== END duplicate line like yyp in vi

;; (load-file "~/.emacs.d/gruvbox/gruvbox-dark-hard-theme.el")
;; (load-theme 'gruvbox-dark-hard;; t)


;; (load-file "~/.emacs.d/eldritch-theme.el")
;; (load-theme 'eldritch;;  t)
;; (use-package doom-themes
;;   :ensure t
;;   :custom
;;   ;; Global settings (defaults)
;;   (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
;;   (doom-themes-enable-italic t) ; if nil, italics is universally disabled
;;   ;; for treemacs users
;;   (doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
;;   :config
;;   (load-theme 'doom-one t)

;;   ;; Enable flashing mode-line on errors
;;   (doom-themes-visual-bell-config)
;;   ;; Enable custom neotree theme (nerd-icons must be installed!)
;;   (doom-themes-neotree-config)
;;   ;; or for treemacs users
;;   (doom-themes-treemacs-config)
;;   ;; Corrects (and improves) org-mode's native fontification.
;;   (doom-themes-org-config))




;; ============== FONT ========================================
;; 1. Set the global default font
(set-face-attribute 'default nil 
                    :family "SauceCodePro Nerd Font" 
                    :height 150 
                    :weight 'medium)

;; 2. Force fixed-pitch and variable-pitch to be identical
;; This "tricks" themes like Poet into staying monospaced
(set-face-attribute 'fixed-pitch nil 
                    :family "SauceCodePro Nerd Font" 
                    :height 1.0 
                    :weight 'medium)

(set-face-attribute 'variable-pitch nil 
                    :family "SauceCodePro Nerd Font" 
                    :height 1.0 
                    :weight 'medium)

;; 3. Clean up Org-mode specifically
(with-eval-after-load 'org
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-block nil :inherit 'fixed-pitch))
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(custom-enabled-themes '(doom-bluloco-dark))
;;  '(custom-safe-themes
;;    '("22a0d47fe2e6159e2f15449fcb90bbf2fe1940b185ff143995cc604ead1ea171"
;;      default))
;;  '(package-selected-packages
;;    '(ace-window atomic-chrome consult doom-themes ef-themes evil
;; 		marginalia markdown-mode orderless org-appear
;; 		org-superstar vertico visual-fill-column)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(cappuccino-noir))
 '(custom-safe-themes
   '("22a0d47fe2e6159e2f15449fcb90bbf2fe1940b185ff143995cc604ead1ea171"
     default))
 '(package-selected-packages
   '(ace-window atomic-chrome consult doom-themes ef-themes evil
		marginalia markdown-mode orderless org-appear
		org-superstar vertico visual-fill-column)))


(load-file "~/.emacs.d/eldritch-theme.el")
(load-theme 'eldritch t)


(setq shift-select-mode t)
;; org-specific fix
(setq org-support-shift-select 'always)	
(setq org-support-shift-select t)
