# qpit-autocomplete package

This Atom pacakge is a helper for input data names in a document database of 'Data Dictionary Tool', provided by the IBM GBS Japan IP Service Component (IPSC), 'Quality and Productivity Improvement toolkit' (a.k.a. QPIT) [IPSC#6949-56B] and its feature 'Support Tools' (Feature#4112).

## Usage

1. Install this package 'qpit-autocomplete'
1. Configure your target database URL and API key and password into settings.
 - the configuration and values should be informed by an administrator of this tools.
1. Execute 'Packages > QPIT AutoComplete > Retrieve  all data model docs'. If your database is alive, qpit-autocomplete creates a cache file on your home directory, named '.qpit-autocomplete.cache'.
1. Execute the menu 'Packages > QPIT AutoComplete > Toggle finder view' or CTRL+SHIFT+SPACE (default keybinding).
 - To invoke a autocompletion of Atom editor, You should input the trigger character(s) as a prefixkeyword, first character and press CTRL+Space to invoke it.
1. Congulatulations! Now you learn the usage of qpit-autocomplete.
