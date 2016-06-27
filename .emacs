;;;;;;;;;;;;;;;;;;;;;;
;; Np3w's emacs config
;;;;;;;;;;;;;;;;;;;;;;

;; Some stuff copied from handmade hero .emacs file

;;;;;;;;;;
;; Config:
;;

;; t = true
;; nil = false

(setq Name "Np3w")
(setq ThemesFolder "~/.emacs.d/themes")
;; If t use smooth scrolling package
(setq EnableSmoothScrolling nil)
;; Directory where packages will be loaded from
(setq LoadPathDirectory "~/.emacs.d/lisp")
;; If true eproject will be loaded
(setq EnableEProject t)
;; If true cmake-ide, irony and flychecks will be loaded
(setq EnableCMakeIde nil)

(setq EnableShowParenMode t)

;; Set the default np3w color scheme
;; Possible values:
;;   "Dark"
;;   "BrighterDark"
;;   "Blue"
;;   "2Colors"
;;   "Solarized"
;;   "None"
(setq Np3wColorScheme "Blue")
;; Should the color scheme be reloaded when loading the .emacs file?
(setq Np3wReloadColorScheme nil)

;;(setq Np3wCodeFont "outline-Liberation Mono")
;;(setq Np3wCodeFont "outline-DejaVu Sans Mono")
;;(setq Np3wCodeFont "Liberation Mono")

;;(setq Np3wCodeFont "Hack")
;;(setq Np3wCodeFont "Arial")
(setq Np3wMonospaceFont "Liberation Mono")
(setq Np3wCodeFont Np3wMonospaceFont)

;;(setq Np3wFontSize 125)
(setq Np3wFontSize 120)

;; TODO(np3w): Compile command on windows
(if (eq system-type 'gnu/linux)
    (setq Np3wBuildCommand "build/build.sh")
  )

(defun np3w-set-build-command (build-command)
  "Set the build command used to build projects"
  (interactive "sEnter build command: ")
  (setq Np3wBuildCommand build-command)
  )

;;
;;;;;;;;;;;;;

;; Error message if all lisp code was not executed(there where errors)
(setq initial-scratch-message "There were errors in .emacs file. Run emacs with --debug-init to debug")

;; Set font face
(set-face-attribute 'default nil
                    :family Np3wCodeFont :height Np3wFontSize)

;; Split window horizontally
(unless (boundp 'np3w-window-setup-done)
  (split-window-horizontally)
  (setq np3w-window-setup-done t)
  )

;; Stuff
(defun np3w-copy-whole-buffer ()
  "Copy whole buffer to kill ring"
  (interactive)
  (kill-new (buffer-string))
  (message "Copied whole buffer")
  )

(defun np3w-re ()
  "(np3w-reload) Reload the .emacs file"
  (interactive)
  (load-file "~/.emacs")
  )

(defun back-to-indentation-or-beginning ()
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
      (beginning-of-line))
  )

(defun np3w-nothing ()
  "Dont do anything"
  )

;; NOTE: Copied from emacs wiki
(defun np3w-copy-whole-line (arg)
  (interactive "p")
  
  (message "np3w-copy-whole-line")
  (kill-ring-save (line-beginning-position) (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s"))
  )

;; Keyboard shortcuts.
;; NOTE: This is for the dvorak programmer keyboard layout

(defvar np3w-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))

    ;; Buffer navigation and finding files
    (define-key map (kbd "M-n") 'find-file)
    (define-key map (kbd "M-N") 'find-file-other-window)
    (define-key map (kbd "M-b") 'ido-switch-buffer)
    (define-key map (kbd "M-B") 'ido-switch-buffer-other-window)
    (define-key map (kbd "M-a") 'np3w-other-window)
    (define-key map (kbd "C-;") 'kill-this-buffer)

    ;; Saving
    (define-key map (kbd "M-o") 'save-buffer)
    
    ;; deletes tab character instead of untabifying it
    (define-key map (kbd "DEL") 'backward-delete-char)
    
    ;; Emacs auto indentation does not work very well sometimes. When that
    ;; happens C-tab can be used to insert the a tab
    (define-key map [C-tab] (lambda () (interactive) (insert "    ")))
    
    ;; Killing and yanking(copy, cut and paste)
    (define-key map (kbd "C-a") 'np3w-copy-whole-buffer)
    (define-key map (kbd "C-.") 'yank)
    (define-key map (kbd "C->") 'yank-pop)

    ;; Line
    (define-key map (kbd "C-e") 'kill-line)
    (define-key map (kbd "C-o") 'kill-whole-line)
    (define-key map (kbd "C-S-o") 'np3w-copy-whole-line)

    ;; Indentation
    (define-key map (kbd "C-u") 'indent-region)
    
    ;; Paragraphs
    (define-key map [prior] 'backward-paragraph)
    (define-key map [next] 'forward-paragraph)

    ;; Jump to beginning of code instead of beginning of line
    (define-key map (kbd "<home>") 'back-to-indentation-or-beginning)

    (define-key map (kbd "C-j") 'next-error)
    (define-key map (kbd "C-k") 'compile)

    ;; Having to write it in minibuffer is very annoying
    (define-key map (kbd "M-/") 'np3w-re)
    
    ;; Mark
    (define-key map (kbd "C-l") 'pop-to-mark-command)
    
    map)
  "my-keys-minor-mode keymap.")
  
(define-minor-mode np3w-keys-minor-mode
  :init-value t
  :lighter " my-keys")

(np3w-keys-minor-mode 1)

(defun np3w-newline ()
  (interactive)

  (insert "\n")
  (indent-for-tab-command)
  )

;; Cannot include it in my minor mode becuase it messes up the minibuffer which
;; binds a special command to RET(overriden by my mode)
(global-set-key (kbd "RET") 'np3w-newline)

;;

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

;; Dont ask for compile command
(setq compilation-read-command nil)

;; Make emacs not forget undo information
(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)

;; Disable selecting text with shift. Markers(C-Space) are used instead
(setq shift-select-mode nil)

;; Remove scroll bar
(scroll-bar-mode -1)
;; Hide annoying toolbar
(tool-bar-mode 0)

(when EnableShowParenMode
  (require 'paren)
  
  (setq show-paren-delay 0.1)
  (setq show-paren-style 'parenthesis)
  (show-paren-mode 1)
  (set-face-attribute 'show-paren-match-face nil :background nil :foreground "#aaa")

  ;; (defadvice show-paren-function
  ;;     (after show-matching-paren-offscreen activate)
  ;;   "If the matching paren is offscreen, show the matching line in the
  ;;       echo area. Has no effect if the character before point is not of
  ;;       the syntax class ')'."
  ;;   (interactive)
  ;;   (let* ((cb (char-before (point)))
  ;;          (matching-text (and cb
  ;;                              (char-equal (char-syntax cb) ?\) )
  ;;                              (blink-matching-open))))
  ;;     (when matching-text (message matching-text)))
  ;;   )
  )

;; Disable bell on windows
(if (eq system-type 'windows-nt)
    (setq visible-bell 1)
)

;; Change emacs backup directory
(setq backup-directory-alist `(("." . "~/EmacsBackups")))

;; Maximize window on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; EProject setup
(when EnableEProject
  (require 'eproject)
  (require 'eproject-extras)

  ;; C++ project mode
  (define-project-type c++ (generic)
    (look-for "CMakeLists.txt")
    ;;:relevant-files ("\\.cpp$" "\\.hpp$")
    )
  (add-hook 'c++-project-file-visit-hook
            (lambda ()
              (make-local-variable 'compile-command)
              (setq compile-command (format "cd %s && %s" eproject-root Np3wBuildCommand))
              )
            )
  )

;;;;;;;;;;;;;;;;;;
;; cmake-ide setup

(when EnableCMakeIde

  ;; RTags setup
  ;;(require 'rtags)

  ;;(global-set-key (kbd "C-b") 'rtags-find-symbol-at-point)
  
  ;; Company mode
  (require 'company)
  (add-hook 'after-init-hook 'global-company-mode)
  
  ;; Flychecks setup
  (require 'flycheck)
  (add-hook 'after-init-hook 'global-flycheck-mode)

  ;; Irony setup
  (require 'irony)
  
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  
  ;; replace the `completion-at-point' and `complete-symbol' bindings in
  ;; irony-mode's buffers by irony-mode's function
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

  ;; Flycheck-irony setup
  (require 'flycheck-irony)
  
  ;;  (eval-after-load 'flycheck
  ;;  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
  (flycheck-irony-setup)

  (require 'cmake-ide)
  (cmake-ide-setup)
  )

;;
;;;;;;;;;;;;;;;;;;

;; Stuff
(load-library "view")
(require 'cc-mode)
(require 'compile)

;; Setting up ido-mode
(require 'ido)
(ido-mode t)
(setq ido-auto-merge-work-directories-length -1)

;; Delete selection when typing or pressing delete
(delete-selection-mode)

;; Disable middle mouse button
(global-unset-key [mouse-2])

;; Load themes folder
(unless nil ThemesFolder
        (add-to-list 'custom-theme-load-path ThemesFolder)
        )

;; Load cmake mode
;;(autoload 'cmake-mode "~/CMake/Auxiliary/cmake-mode.el" t)
(load-file "~/CMake/Auxiliary/cmake-mode.el")
;;require('cmake-mode)

;; Auto mode
(setq auto-mode-alist
      (append
       '(("\\.cpp$" . c++-mode)
         ("\\.hin$" . c++-mode)
         ("\\.cin$" . c++-mode)
         ("\\.inl$" . c++-mode)
         ("\\.rdc$" . c++-mode)
         ("\\.h$" . c++-mode)
         ("\\.hpp$" . c++-mode)
         ("\\.c$" . c++-mode)
         ("\\.cc$" . c++-mode)
         ("\\.c8$" . c++-mode)
         ("\\.txt$" . indented-text-mode)
         ("\\.emacs$" . emacs-lisp-mode)
         ("\\.gen$" . gen-mode)
         ("\\.ms$" . fundamental-mode)
         ("\\.m$" . objc-mode)
         ("\\.mm$" . objc-mode)
         ("\\.py$" . python-mode)
         ("\\.java$" . java-mode)
         '(("CMakeLists\\.txt\\'" . cmake-mode))
         '(("\\.cmake\\'"         . cmake-mode))
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

(setq c-default-style "bsd")


;; Dont split windows. Use existing windows instead
(defun np3w-never-split-a-window
    nil
  )
(setq split-window-preferred-function 'np3w-never-split-a-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

;; Dont show the compilation buffer if there was no errors
;; NOTE Copied from http://stackoverflow.com/questions/17659212/dont-display-compilation-buffer-in-emacs-until-the-process-exits-with-error-o
;; and
;; http://stackoverflow.com/questions/11043004/emacs-compile-buffer-auto-close

(defun np3w-compile-finish (buffer outstr)
  (unless (and
           (string-match "finished" outstr)
           (not
            (with-current-buffer buffer
              (goto-char 1)
              (search-forward "warning" nil t)))
           )
    (switch-to-buffer-other-window buffer)
    )
  )
(setq compilation-finish-functions 'np3w-compile-finish)
(require 'cl)
(defadvice compilation-start
    (around inhibit-display
            (command &optional mode name-function highlight-regexp)) 
  (if (not (string-match "^\\(find\\|grep\\)" command))
      ;; TODO: Emacs complains about this and tells me to replace it with
      ;; cl-flet which breaks everything.
      (flet ((display-buffer)
             (set-window-point)
             (goto-char)
             )
        (fset 'display-buffer 'ignore)
        (fset 'goto-char 'ignore)
        (fset 'set-window-point 'ignore)
        (save-window-excursion ad-do-it))
    ad-do-it)
  )
(ad-activate 'compilation-start)

;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
              indent-tabs-mode nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fix enum class indentation
;; From: https://gist.github.com/nschum/2626303

(defun inside-class-enum-p (pos)
  "Checks if POS is within the braces of a C++ \"enum class\"."
  (ignore-errors
    (save-excursion
      (goto-char pos)
      (up-list -1)
      (backward-sexp 1)
      (looking-back "enum[ \t]+class[ \t]+[^}]*"))))

(defun align-enum-class (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      0
    (c-lineup-topmost-intro-cont langelem)))

(defun align-enum-class-closing-brace (langelem)
  (if (inside-class-enum-p (c-langelem-pos langelem))
      '-
    '+))

(defun fix-enum-class ()
  "Setup `c++-mode' to better handle \"class enum\"."
  (add-to-list 'c-offsets-alist '(topmost-intro-cont . align-enum-class))
  (add-to-list 'c-offsets-alist
               '(statement-cont . align-enum-class-closing-brace)))

(add-hook 'c++-mode-hook 'fix-enum-class)

;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;; Setup key bindings:

;; Switch to buffer in other window
(defun np3w-other-window ()
  (interactive)
  (other-window 1)
  )

;;
;;;;;;;;;;;;;;;;;;;;;;

;; Set scratch buffer message
(setq initial-scratch-message "")

;; Initialization that in only done once even if this file is reloaded
;;(defun np3w-post-load ()
;;
;;  )
;;(add-hook 'window-setup-hook 'np3w-post-load t)

(interactive)
(menu-bar-mode -1)

;; Custom keywords
(setq np3w-c-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(mapc (lambda (mode)
        (font-lock-add-keywords
         mode
         '(("\\<\\(FIXME\\|TODO\\|BUG\\)" 1 'font-lock-fixme-face t)
           ("\\<\\(NOTE\\)" 1 'font-lock-note-face t)
           ("\\<\\(nullptr\\)" 1 'font-lock-keyword-face t))))
      np3w-c-modes)

;; Force monospace fonts in some modes
(defun np3w-buffer-set-monospace-font ()
  (interactive)
  (message "Setting buffer face to Np3wMonospaceFont")
  (setq buffer-face-mode-face `(:family ,Np3wMonospaceFont :height ,Np3wFontSize))
  (buffer-face-mode)
  )

(add-hook 'compilation-mode-hook 'np3w-buffer-set-monospace-font)

(defun np3w-theme (theme-string)
  (interactive "sEnter theme name: ")
  (when (string= theme-string "Dark")
    ;; Use dark backround
    (set-foreground-color "burlywood3")
    (set-background-color "#1a1a1a")

    ;; Green cursor
    (set-cursor-color "#40FF40")

    ;; Change colors
    ;;(set-face-attribute 'region nil :background "blue3")
    (set-face-attribute 'region nil :background "#2a2a2a")

    (set-face-attribute 'font-lock-constant-face nil      :foreground "burlywood3")
    (set-face-attribute 'font-lock-keyword-face nil       :foreground "#c99e12")

    (set-face-attribute 'font-lock-type-face nil          :foreground "#burlywood3")
    (set-face-attribute 'font-lock-function-name-face nil :foreground "burlywood3")
    (set-face-attribute 'font-lock-variable-name-face nil :foreground "burlywood3")

    (set-face-attribute 'font-lock-comment-face nil       :foreground "#ababab")
    (set-face-attribute 'font-lock-preprocessor-face nil  :foreground "#ababab")

    (set-face-attribute 'font-lock-string-face nil        :foreground "#57a61c")

    (set-face-attribute 'font-lock-builtin-face nil       :foreground "#ababab")

    ;; Colored numbers
    (add-hook 'after-change-major-mode-hook
              '(lambda () (font-lock-add-keywords 
                           nil 
                           '(("\\([0-9]+\\)" 
                              1 font-lock-string-face)))))
    (modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
    (modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)
    )

  (when (string= theme-string "BrighterDark")
    ;; Use dark backround
    (setq np3w-foreground "#D1B086")
    
    (set-foreground-color np3w-foreground)
    (set-background-color "#242222")

    ;; Green cursor
    (set-cursor-color "#40FF40")

    ;; Change colors
    ;;(set-face-attribute 'region nil :background "blue3")
    (set-face-attribute 'region nil :background "#202020")

    (set-face-attribute 'font-lock-constant-face nil      :foreground np3w-foreground)
    (set-face-attribute 'font-lock-keyword-face nil       :foreground "#D1A30D")

    (set-face-attribute 'font-lock-type-face nil          :foreground "#799624")
    (set-face-attribute 'font-lock-function-name-face nil :foreground np3w-foreground)
    (set-face-attribute 'font-lock-variable-name-face nil :foreground np3w-foreground)

    (set-face-attribute 'font-lock-comment-face nil       :foreground "#ababee")
    (set-face-attribute 'font-lock-preprocessor-face nil  :foreground "#ababee")

    (set-face-attribute 'font-lock-string-face nil        :foreground "#64BF21")
    
    (set-face-attribute 'font-lock-builtin-face nil       :foreground "#ababab")

    ;; Colored numbers
    (add-hook 'after-change-major-mode-hook
              '(lambda () (font-lock-add-keywords 
                           nil 
                           '(("\\([0-9]+\\)" 
                              1 font-lock-string-face)))))
    (modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
    (modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)
    )
  (when (string= theme-string "Blue")
    ;; Use dark backround
    (setq np3w-foreground "#dedede")
    
    (set-foreground-color np3w-foreground)
    (set-background-color "#333355")

    ;; Green cursor
    (set-cursor-color "#40dd40")

    ;; Change colors
    (set-face-attribute 'region nil :background "#224")

    (set-face-attribute 'font-lock-constant-face nil      :foreground np3w-foreground)
    ;;(set-face-attribute 'font-lock-keyword-face nil       :foreground "#A842A7")
    (set-face-attribute 'font-lock-keyword-face nil       :foreground "#0099ff")

    (set-face-attribute 'font-lock-type-face nil          :foreground np3w-foreground)
    (set-face-attribute 'font-lock-function-name-face nil :foreground np3w-foreground)
    (set-face-attribute 'font-lock-variable-name-face nil :foreground np3w-foreground)

    (set-face-attribute 'font-lock-comment-face nil       :foreground "#aa1")
    (set-face-attribute 'font-lock-preprocessor-face nil  :foreground "#aa1")

    (set-face-attribute 'font-lock-string-face nil        :foreground "#e6903e")
    
    (set-face-attribute 'font-lock-builtin-face nil       :foreground "#ababab")
    (set-face-attribute 'comint-highlight-prompt nil     :foreground "#3388de")

    ;; Colored numbers
    (add-hook 'after-change-major-mode-hook
              '(lambda () (font-lock-add-keywords 
                           nil 
                           '(("\\([0-9]+\\)" 
                              1 font-lock-string-face)))))
    (modify-face 'font-lock-fixme-face "#ee3333" nil nil t nil t nil nil)
    (modify-face 'font-lock-note-face "#493" nil nil t nil t nil nil)
    )

  (when (string= theme-string "2Colors")
    ;; Use dark backround
    (setq np3w-black "#2a2a2a")
    (setq np3w-white "#cccccc")
    
    (set-foreground-color np3w-black)
    (set-background-color np3w-white)

    (set-cursor-color "#444444")
    
    ;; Change colors
    ;;(set-face-attribute 'region nil :background "blue3")
    (set-face-attribute 'region nil :background "#9999a0")

    (set-face-attribute 'font-lock-constant-face nil      :foreground np3w-black)
    (set-face-attribute 'font-lock-keyword-face nil       :foreground np3w-black)

    (set-face-attribute 'font-lock-type-face nil          :foreground np3w-black)
    (set-face-attribute 'font-lock-function-name-face nil :foreground np3w-black)
    (set-face-attribute 'font-lock-variable-name-face nil :foreground np3w-black)

    (set-face-attribute 'font-lock-comment-face nil       :foreground np3w-black)
    (set-face-attribute 'font-lock-preprocessor-face nil  :foreground np3w-black)

    (set-face-attribute 'font-lock-string-face nil        :foreground np3w-black)
    (set-face-attribute 'font-lock-builtin-face nil       :foreground np3w-black)

    ;; Custom keywords
    (modify-face 'font-lock-fixme-face np3w-black nil nil t nil t nil nil)
    (modify-face 'font-lock-note-face np3w-black nil nil t nil t nil nil)
    )
  (when (string= theme-string "Solarized")
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Colors
    
    (setq s_base03    "#002b36")
    (setq s_base02    "#073642")
    (setq s_base01    "#586e75")
    (setq s_base00    "#657b83")
    (setq s_base0     "#839496")
    (setq s_base1     "#93a1a1")
    (setq s_base2     "#eee8d5")
    (setq s_base3     "#fdf6e3")
    (setq s_yellow    "#b58900")
    (setq s_orange    "#cb4b16")
    (setq s_red       "#dc322f")
    (setq s_magenta   "#d33682")
    (setq s_violet    "#6c71c4")
    (setq s_blue      "#268bd2")
    (setq s_cyan      "#2aa198")
    (setq s_green     "#859900")
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    (set-foreground-color s_base0)
    (set-background-color s_base03)

    (set-cursor-color s_base0)
    
    ;; Change colors
    (set-face-attribute 'region nil :background s_base02)

    (set-face-attribute 'font-lock-constant-face nil      :foreground s_cyan)
    (set-face-attribute 'font-lock-keyword-face nil       :foreground s_green)

    (set-face-attribute 'font-lock-type-face nil          :foreground s_yellow)
    (set-face-attribute 'font-lock-function-name-face nil :foreground s_base0)
    (set-face-attribute 'font-lock-variable-name-face nil :foreground s_base0)

    (set-face-attribute 'font-lock-comment-face nil       :foreground s_base01)
    (set-face-attribute 'font-lock-preprocessor-face nil  :foreground s_orange)

    (set-face-attribute 'font-lock-string-face nil        :foreground s_cyan)
    (set-face-attribute 'font-lock-builtin-face nil       :foreground s_green)
    
    (set-face-attribute 'compilation-warning nil          :foreground s_orange)
    (set-face-attribute 'compilation-error nil            :foreground s_red)
    
    (set-face-attribute 'font-lock-fixme-face nil         :foreground s_magenta)
    
    
    ;; Colored numbers
    (add-hook 'after-change-major-mode-hook
              '(lambda () (font-lock-add-keywords 
                           nil 
                           '(("\\([0-9]+\\)" 
                              1 font-lock-string-face)))))
    )
  )

(unless (boundp 'np3w-color-scheme-set)
  (np3w-theme Np3wColorScheme)
  (setq np3w-color-scheme-set t)
  )
(if Np3wReloadColorScheme
    (np3w-theme Np3wColorScheme)
    )

;; END of file. If there is any code below this it is generated by emacs
