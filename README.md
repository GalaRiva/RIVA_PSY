
# RIVA PSY

<div>
  <h1 align="center">Getting Started with Flutter 🚀</h1>
  <p>
    A completely practical application for you to cope with panic attacks and a state of affect at the moment,
    work out heavy emotions and feelings, find hidden connections that worsen your well-being.
    Filling in the SMER is as simple as possible, and you can send it to your psychologist from the application.
  </p>
</div>


### Table of Contents
- [System Requirements](#system-requirements)
- [Figma design guidelines for better accuracy](#figma-design-guideline-for-better-accuracy)
- [App Navigations](#app-navigations)
- [Project Structure](#project-structure)
- [How you can do code formatting?](#how-you-can-do-code-formatting)
- [How you can improve the readability of code?](#how-you-can-improve-the-readability-of-code)
- [Libraries and tools used](#libraries-and-tools-used)
- [Support](#support)

### System Requirements

Dart SDK Version 2.18.0 or greater.
Flutter SDK Version 3.3.0 or greater.

### Figma design guidelines for better accuracy

Read our guidelines to increase the accuracy of design conversion to code by optimizing Figma designs.
https://docs.dhiwise.com/docs/Designguidelines/intro

### App Navigations

Check your app's UI from the AppNavigation screen of your app.

### Project Structure
                After successful build, your application structure should look like this:
                    
```
.
├── android                         - contains files and folders required for running the application on an Android operating system.
├── assets                          - contains all images and fonts of your application.
├── ios                             - contains files required by the application to run the dart code on iOS platforms.
├── lib                             - Most important folder in the project, used to write most of the Dart code.
    ├── main.dart                   - starting point of the application
    ├── core
    │   ├── app_export.dart         - contains commonly used file imports 
    │   ├── constants               - contains static constant class file
    │   └── utils                   - contains common files and utilities of project
    ├── presentation                
    │   └── screens                 - contains all screens
    ├── routes                      - contains all the routes of application
    └── theme                       - contains app theme and decoration classes
    └── widgets                     - contains all custom widget classes
```
### How you can do code formatting?

- if your code is not formatted then run following command in your terminal to format code
  ```
  dart format .
  ```

### How you can improve the readability of code?

Resolve the errors and warnings that are shown in the application.

### Support

If you have problems or questions go to our Discord channel, we will then try to help you as quickly as possible: https://discord.com/invite/rFMnCG5MZ7
