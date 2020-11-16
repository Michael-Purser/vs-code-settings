# Using This Settings File

Clone this repository in the location of your VSCode settings (typically `~/.config/Code/User`).

# VSCode extensions

Below is a list of all extensions I use with VSCode, as well as some instructions on how to set up some of them.

## Currently Installed Extensions

 - `Clang-format`
 - `clangd`
 - `Cmake Tools`
 - `Jsonnet Language Support`
 - `Markdown Preview Github Styling`
 - `Python`
 - `shellCheck`
 - `Spacegray VSCode`


## Setting Up Clang-format

Setting up clang format is explained in the clang-format documentation. <br/>
In this repository I therefore only provide the `.clang-format` file that I currently use. <br/>

To use it:
 - Added a symlink to this `.clang-format` file at the top of the project source tree.
 - Add the generated symlink to the project's `.gitignore` file. In case it is not possible to edit the `.gitignore` file (e.g. in a shared repository where this may break things for other people or where an (annoying) PR is needed to merge it), you can add it to the `.git/info/exclude` file instead.


## Setting Up Clangd

### For a non-ROS workspace

1. Install the `clangd` extension.
2. Open a C++ source code file - VSCode will automatically ask to download the clangd server. <br/>
   *This is currently the way I do it, as I have not found a way to make the extension work with a clangd-server installed with a debian package manager such as `apt-get` or `apt`.*
3. Make sure the project build flags are set to export compile commands.
4. Build the project again to generate the compile commands.
5. Add a symbolic link to the generated compile commands file at the top of the project source tree.
6. Add the generated symbolic link to the project's `.gitignore` file or to `.git/info/exclude` depending on your needs (as explained in the section about setting up Clang-format).

### For a ROS workspace

1. Follow steps 1.-4. above.
2. A ROS-workspace typically contains one compile commands file per package. <br/>
   To avoid having to create a bunch of symbolic links manually, I suggest using a script to automate this process. <br/>
   An example of such a script tailored to the Enway source and build spaces can be found in this repository. <br/>
   This has the advantage of being quick when switching branches (switch branches, build again and run the command). <br/>
   I recommend creating an alias to build and add the symbolic links in one go.
