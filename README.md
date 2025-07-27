<div align="center">

# modern-icons-helm.el

Modern icons for Emacs [helm](https://github.com/emacs-helm/helm).

</div>

This library integrates [modern-icons.el](https://github.com/taquangtrung/modern-icons.el) to display modern and pretty SVG icons for [helm](https://github.com/emacs-helm/helm) completion results in Emacs.

## Installation

Install from Melpa (supported soon) or manually using [straight.el](https://github.com/radian-software/straight.el) like below:

```elisp
(use-package modern-icons
  :straight (modern-icons :type git :host github
                          :repo "taquangtrung/modern-icons-helm.el"))
```

## Usage

Include the following code into your configuration file:

```elisp
(require 'modern-icons-helm)
(modern-icons-helm-enable)
```

## Screenshots

- helm-find-files:

  <p align="center">
    <img width="600" alt="Modern icons for helm-find-files" src="screenshots/modern-icons-helm-find-files.png"/>
  </p>

- helm-imenu:

  <p align="center">
    <img width="600" alt="Modern icons for helm-imenu" src="screenshots/modern-icons-helm-imenu.png"/>
  </p>

## Acknowledgements

This library is inspired by [helm-icons](https://github.com/yyoncho/helm-icons/).
