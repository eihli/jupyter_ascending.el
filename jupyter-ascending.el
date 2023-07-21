;;; jupyter-ascending-mode.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Eric Ihli
;;
;; Author: Eric Ihli <eihli@owoga.com>
;; Maintainer: Eric Ihli <eihli@owoga.com>
;; Created: November 28, 2022
;; Modified: November 28, 2022
;; Version: 0.0.1
;; Keywords: languages jupyter
;; Homepage: https://github.com/eihli/jupyter-ascending-mode
;; Package-Requires: ((emacs "24.4"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Jupyter Ascending lets you edit Jupyter notebooks from your favorite editor,
;;  then instantly sync and execute that code in the Jupyter notebook running in
;;  your browser.
;;
;;  The project is hosted at https://github.com/untitled-ai/jupyter_ascending
;;
;;  This package adds a couple interactive commands and keyboard shortcuts for
;;  syncing/executing with the jupyter_ascending Python package.
;;
;;; Code:

(require 'python)

(defun jupyter-ascending-sync ()
  "Run `async-shell-command' to sync the current file with the notebook."
  (interactive)
  (async-shell-command
   (format "%s -m jupyter_ascending.requests.sync --filename \"%s\""
           python-shell-interpreter
           (buffer-file-name))))

(defun jupyter-ascending-execute ()
  "Run `async-shell-command' to execute the current line in the notebook."
  (interactive)
  (async-shell-command
   (format "%s -m jupyter_ascending.requests.execute --filename \"%s\" --linenumber \"%s\""
           python-shell-interpreter
           (buffer-file-name)
           (line-number-at-pos))))

(define-minor-mode jupyter-ascending-mode
  "Mode to sync Python files with Jupyter Notebooks."
  :lighter " jupyter-ascending"
  :keymap (let ((keymap (make-sparse-keymap)))
            (define-key keymap (kbd "C-S-s") 'jupyter-ascending-sync)
            (define-key keymap (kbd "C-S-e") 'jupyter-ascending-execute)
            keymap)
  (if jupyter-ascending-mode
      (progn
        (add-to-list 'display-buffer-alist `(,shell-command-buffer-name-async (display-buffer-no-window)))
        (add-hook 'after-save-hook #'jupyter-ascending-sync))
    (progn
      (setq display-buffer-alist (remove `(,shell-command-buffer-name-async (display-buffer-no-window)) display-buffer-alist))
      (remove-hook 'after-save-hook #'jupyter-ascending-sync))))

(provide 'jupyter-ascending)
;;; jupyter-ascending-mode.el ends here
