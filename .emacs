;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                               Local functions                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun install-if-not (pkg)
  "Install the package if it's not initialized"
  (unless (require pkg) (package-install pkg)))

(defun mkdir-if-not (dir)
  "Make directory if it doesn't exist"
  (unless (file-exists-p dir) (mkdir dir)))

(defun load-if-exists (file)
  "Load file if it exists"
  (unless (file-exists-p file) (load-file file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                 Imports                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq require-packages
  '(
    circe
    groovy-mode
    ido
    jira
    haskell-mode
    highlight
    highlight-parentheses
    tree-mode
    undo-tree
    windata
    xclip
    zossima
))

;;; ELPA packages
(when (>= emacs-major-version 24)
  (require 'package)
  (setq package-archives
	'(
	  ("gnu" . "http://elpa.gnu.org/packages/")
	  ("marmalade" . "http://marmalade-repo.org/packages/")
	  ("melpa" . "http://melpa.milkbox.net/packages/")))
  (package-refresh-contents)
  (package-initialize)
  (mapcar 'install-if-not require-packages)
  (package-initialize)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                             Global functions                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun json-format ()
  "Format JSON in region by piping to python's json.tool"
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)n
  )
)

(defun metachar-cleanup ()
  "Replaces escaped metacharacters in the region with their literal characters"
  (interactive)
  (save-restriction
    (narrow-to-region (point) (mark))
    (goto-char (point-min))
    (while (search-forward "\\n" nil t) (replace-match "\n" nil t))
    (goto-char (point-min))
    (while (search-forward "\\t" nil t) (replace-match "\t" nil t))
    (goto-char (point-min))
    (while (search-forward "\\r" nil t) (replace-match "" nil t))
    (goto-char (point-min))
    (while (search-forward "\\\"" nil t) (replace-match "\"" nil t))
    (goto-char (point-min))
    (while (search-forward "\\'" nil t) (replace-match "'" nil t))
))

(defun move-to-center-column ()
  "Moves the point to the center of the current line"
  (interactive)
  (let
    ((line-len (save-excursion (end-of-line) (current-column))))
  (move-to-column (/ line-len 2))
))

(defun delete-word (arg)
  "Delete characters forward until encountering the end of a word.
  With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point)))
)

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
  With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (backward-word arg) (point)))
)

(defun unix-werase-or-kill (arg)
  "If transient mark mode is active, perform 'kill-region, else perform
  'backward-delete-word."
      (interactive "*p")
      (if (and transient-mark-mode
	          mark-active)
          (kill-region (region-beginning) (region-end))
        (backward-delete-word arg)))

(defun keyring (ring user)
  "Returns a password from the keyring"
  (interactive)
  (insert ring user))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                               Global modes                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; global-highlight-parentheses-mode
(when (require 'highlight-parentheses)
  (define-globalized-minor-mode global-highlight-parentheses-mode
    highlight-parentheses-mode
    (lambda () (highlight-parentheses-mode t)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                 Bindings                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; General keybindings
(global-set-key (kbd "C-w") 'unix-werase-or-kill)
(global-set-key (kbd "C-x r i") 'string-insert-rectangle)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-d") 'delete-word)
(global-set-key (kbd "M-n") 'move-to-center-column)
(global-set-key (kbd "M-s M-s") 'replace-regexp)

;;; Mode keybindings
(global-unset-key (kbd "C-x m")) ; unset 'compose-mail
(global-set-key (kbd "C-x m e") 'emacs-lisp-mode)
(global-set-key (kbd "C-x m f") 'flymake-mode)
(global-set-key (kbd "C-x m h") 'haskell-mode)
(global-set-key (kbd "C-x m i") 'jira-mode)
(global-set-key (kbd "C-x m l") 'linum-mode)
(global-set-key (kbd "C-x m o") 'org-mode)
(global-set-key (kbd "C-x m p") 'python-mode)
(global-set-key (kbd "C-x m s") 'shell-script-mode)
(global-set-key (kbd "C-x m w") 'whitespace-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                   Config                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Configure backups
(mkdir-if-not "~/.emacs.d/backups")
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq backup-by-copying t)

;;; Set modes
(column-number-mode t)			; (line, column)
(when (require 'undo-tree)		; Enable undo tree
  (global-undo-tree-mode 1))
(when (require 'ido)			; Enable interactive-do mode
  (ido-mode t))
(when (require 'highlight-parentheses)
  (global-highlight-parentheses-mode t))

;;; General config
(setq linum-format "%s ")	                          ; add space after line numbers
(fset 'yes-or-no-p 'y-or-n-p)	                          ; All 'yes/no' prompts show 'y/n'
(set-display-table-slot standard-display-table 'wrap ?\ ) ; remove linewrap '\'
(put 'downcase-region 'disabled nil)

;;; Flymake config
(custom-set-faces
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))

;;; Python config
(setq
  python-shell-interpreter "ipython"
  python-shell-interpreter-args ""
  python-shell-prompt-regexp "In \\[[0-9]+\\]: "
  python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
  python-shell-completion-setup-code
    "from IPython.core.completerlib import module_completion"
  python-shell-completion-module-string-code
    "';'.join(module_completion('''%s'''))\n"
  python-shell-completion-string-code
    "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

;;; Hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                       Secure/Hidden/Client-specific                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Digital Reasoning
(load-if-exists "~/.emacs.d/personal/digitalreasoning.el")
