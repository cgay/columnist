# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

sys.path.insert(0, os.path.abspath('../../_packages/sphinx-extensions/current/src/sphinxcontrib'))

import dylan.domain

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'columnist'
copyright = '2025, Carl Gay'
author = 'Carl Gay'
release = '0.2.0'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'dylan.domain',
    'sphinx.ext.intersphinx'
]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build']

# This makes it so that each document doesn't have to use
#   .. default-domain:: dylan
# but they probably should anyway, so that they can be built separately
# without depending on this top-level config file.
primary_domain = 'dylan'

# sudo pip install -U furo
html_theme = 'furo'

# Ignore SNI validation errors
tls_verify = False
