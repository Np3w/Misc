;;;;;;;;;;;;;;;;;;;;;;
;; Np3w's emacs config
;;;;;;;;;;;;;;;;;;;;;;

;; Some stuff copied from handmade hero .emacs file



;;;;;;;;;;;;;;;;;;;;;;
;; Keyboard shortcuts:
;; 
;; M-i = Find file
;; M-U = Find file in other window
;; M-x = Switch buffer
;; M-X = Switch buffer in other window
;; M-o = Save buffer 
;; M-a = Switch to other window
;; C-S = Search In Buffer
;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;
;; Config:

;; t = true
;; nil = false

(setq Name "Np3w")
(setq ThemesFolder "~/.emacs.d/themes")
;; If t use smooth scrolling package
(setq EnableSmoothScrolling t)
;; Directory where packages will be loaded from
(setq LoadPathDirectory "~/.emacs.d/lisp")
;; If true eproject will be loaded
(setq EnableEProject t)

;;
;;;;;;;;;;;

;; Enable MELPA packages
;; Use "list-packages" to browse packages
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
  )
(package-initialize)

;; Add load path
(add-to-list 'load-path LoadPathDirectory)

;; Make emacs not forget undo information
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

;; Disable selecting text with shift. Markers(C-Space) are used instead
(setq shift-select-mode nil)

;; Remove scroll bar
(scroll-bar-mode -1)
;; Hide annoying toolbar
(tool-bar-mode 0)

;; Change emacs backup directory
(setq backup-directory-alist `(("." . "~/EmacsBackups")))

;; Maximize window on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; EProject setup
(when EnableEProject
  (require 'eproject)
  (require 'eproject-extras)
  
  ;; Copied from the eproject github page
  (defmacro .emacs-curry (function &rest args)
	`(lambda () (interactive)
	   (,function ,@args)))
  
  (defmacro .emacs-eproject-key (key command)
	(cons 'progn
		  (loop for (k . p) in (list (cons key 4) (cons (upcase key) 1))
				collect
				`(global-set-key
				  (kbd ,(format "M-p %s" k))
				  (.emacs-curry ,command ,p)))))
  
  (.emacs-eproject-key "k" eproject-kill-project-buffers)
  (.emacs-eproject-key "v" eproject-revisit-project)
  (.emacs-eproject-key "b" eproject-ibuffer)
  (.emacs-eproject-key "o" eproject-open-all-project-files)
  )

;;;;;;;;;;;;;;;;;;
;; cmake-ide setup
(require 'rtags)
(require 'flycheck)

;; Flycheck config
(global-flycheck-mode)

(cmake-ide-setup)

;;
;;;;;;;;;;;;;;;;;;

;; Stuff
(load-library "view")
(require 'cc-mode)
(require 'ido)
(require 'compile)
(ido-mode t)

;; Disable middle mouse button
(global-unset-key [mouse-2])

;; Load themes folder
(unless nil ThemesFolder
		(add-to-list 'custom-theme-load-path ThemesFolder)
		)

;; Colored TODO and NOTE
(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(mapc (lambda (mode)
		(font-lock-add-keywords
		 mode
		 '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
		   ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
	  fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)

;; Load cmake mode
;;(autoload 'cmake-mode "~/CMake/Auxiliary/cmake-mode.el" t)
;;(load-file "~/CMake/Auxiliary/cmake-mode.el")

;; Auto mode
(setq auto-mode-alist
	  (append
	   '(("\\.cpp$"	   . c++-mode)
		 ("\\.hin$"	   . c++-mode)
		 ("\\.cin$"	   . c++-mode)
		 ("\\.inl$"	   . c++-mode)
		 ("\\.rdc$"	   . c++-mode)
		 ("\\.h$"	   . c++-mode)
 		 ("\\.hpp$"	   . c++-mode)
		 ("\\.c$"	   . c++-mode)
		 ("\\.cc$"	   . c++-mode)
		 ("\\.c8$"	   . c++-mode)
		 ("\\.txt$"	   . indented-text-mode)
		 ("\\.emacs$"  . emacs-lisp-mode)
		 ("\\.gen$"	   . gen-mode)
		 ("\\.ms$"	   . fundamental-mode)
		 ("\\.m$"	   . objc-mode)
		 ("\\.mm$"	   . objc-mode)
		 '(("CMakeLists\\.txt\\'" . cmake-mode))
		 '(("\\.cmake\\'"		  . cmake-mode))
		 ) auto-mode-alist))

;; C++ indendetion style
;;(defconst np3w-cc-style
;;  '("cc-mode"
;;    (c-offsets-alist . ((innamespace . [0])))))

;;(c-add-style "np3w-cc-mode" np3w-cc-style)

(c-set-offset 'innamespace 0)
;;;;;;;;;;;;;;;;;;;;;;;;;
;; Indent code like this:
;; if (true)
;; {
;;     ...
;; }
;;;;;;;;;;;;;;;;;;;;;;;;;

(setq c-default-style "linux")

;; Split window horizontally
(split-window-horizontally)

;; Dont split windows. Use existing windows instead
(defun np3w-never-split-a-window
	nil
  )
(setq split-window-preferred-function 'np3w-never-split-a-window)

;; Dont hightlight matching parenthesis
(show-paren-mode 0)

;; Smooth scrolling
(setq redisplay-dont-pause t)

(when EnableSmoothScrolling
  (require 'smooth-scrolling)
  (smooth-scrolling-mode 1)
  )

(unless EnableSmoothScrolling
  (setq scroll-step 1)
 )

;; Disable cursor blinking
(blink-cursor-mode 0)

;; Indentation settings
(setq-default c-basic-offset 4
			  tab-width 4
			  indent-tabs-mode t)

;;;;;;;;;;;;;;;;;;;;;;
;; Setup key bindings:

;; Switch to buffer in other window
(defun np3w-other-window ()
  (interactive)
  (other-window 1)
  )

(defvar np3w-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-i") 'find-file)
	(define-key map (kbd "M-I") 'find-file-other-window)
	(define-key map (kbd "M-b") 'ido-switch-buffer)
	(define-key map (kbd "M-B") 'ido-switch-buffer-other-window)
	(define-key map (kbd "M-a") 'np3w-other-window)
	(define-key map (kbd "M-o") 'save-buffer)
	(define-key map (kbd "DEL") 'backward-delete-char) ; deletes tab character instead of untabifying it
    map)
  "my-keys-minor-mode keymap.")

(define-minor-mode np3w-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-keys")

(np3w-keys-minor-mode 1)

;; Find file
;;(define-key global-map (kbd "M-i") 'find-file)
;;(define-key global-map (kbd "M-U") 'find-file-other-window)

;; Switch buffer
;;(global-set-key (kbd "M-b")	 'ido-switch-buffer)
;;(global-set-key (kbd "M-B")	 'ido-switch-buffer-other-window)

;;(global-set-key (kbd "M-a") 'np3w-other-window)

;; Save buffer
;;(global-set-key (kbd "M-o") 'save-buffer)

;;
;;;;;;;;;;;;;;;;;;;;;;

;; Set scratch buffer message
(setq initial-scratch-message "")

(defun np3w-post-load ()
  (interactive)
  (menu-bar-mode -1)
  ;; Use dark backround
  (set-foreground-color "burlywood3")
  (set-background-color "#161616")
  ;; Green cursor
  (set-cursor-color "#40FF40")
  ;; Change region color
  (set-face-attribute 'region nil :background blue3)
  )
(add-hook 'window-setup-hook 'np3w-post-load t)

;; END
