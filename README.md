# to_webp command line utility
This dart command utility is made to facilitate converting .jpg and 
.png images to .webp. The main advantage of using this program is the
possibility to convert all files from a particular directory and its
subdirectories at once, while keeping the original directories structure.

## Example usage
Imagine that you have the following file structure:
    images/
     home_screen/
      avatars/
       avatar_1.jpg
       avatar_2.jpg
      backgrounds/
       bg_1.png
       bg_2.png  
     placeholders/
      placeholder_1.png

after using this utility with the images folder as --src you will get
the following structure:
    [destination dir]/
     home_screen/
      avatars/
       avatar_1.webp
       avatar_2.webp
      backgrounds/
       bg_1.webp
       bg_2.webp 
     placeholders/
      placeholder_1.webp

## Usage
    cmd> to_webp --src <source directory> --dst <destination directory> [-q <0-100>]

Where:
* --src <source directory> - relative or absolute path to the directory with
the images to be converted.
* --dst <destination directory> - relative or absolute path to the directory
in which the converted images will be placed. If it doesn't exist then
it will be created.
* -q <0-100> - compression rate, 0 -> max. compression, 100 -> no compression

## Installation
1. If you use a windows machine, then download the to_web.exe file.
If you use other operating system, then you must build the bin/main.dart
file to meet your system requirements.
2. Download cwebp encoder, e.g. from [here](https://developers.google.com/speed/webp/download).
3. Put the files obtained in step 1 and 2 (to_webp and cweb) in the same
directory.
4. You can run the program by opening command line in the directory
in which you put the files by using the command from the Usage section
or you can add path to this directory to your environmental variables
and run the command anywhere.

# License
I do not take responsibility for any potential harms done by the program,
nor do I guarantee that it works properly. Besides that files from this
directory can be used in any way. As for the cweb, respect the cweb's
license.

 