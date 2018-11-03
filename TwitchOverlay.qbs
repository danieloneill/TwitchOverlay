import qbs

Project {
    minimumQbsVersion: "1.7.1"

    CppApplication {
        id: myApp
        Depends { name: "Qt.core" }
        Depends { name: "Qt.quick" }
        Depends { name: 'Qt.widgets' }
        Depends { name: 'Qt.quickwidgets' }

        // Additional import path used to resolve QML modules in Qt Creator's code model
        property pathList qmlImportPaths: [ 'qml' ]

        cpp.cxxLanguageVersion: "c++11"

        cpp.defines: [
            // The following define makes your compiler emit warnings if you use
            // any feature of Qt which as been marked deprecated (the exact warnings
            // depend on your compiler). Please consult the documentation of the
            // deprecated API in order to know how to port your code away from it.
            "QT_DEPRECATED_WARNINGS",

            // You can also make your code fail to compile if you use deprecated APIs.
            // In order to do so, uncomment the following line.
            // You can also select to disable deprecated APIs only up to a certain version of Qt.
            //"QT_DISABLE_DEPRECATED_BEFORE=0x060000" // disables all the APIs deprecated before Qt 6.0.0
        ]

        Group {
            name: 'Common'
            files: [
                "main.cpp",
                "overlay.cpp",
                "overlay.h",
                "qml.qrc",
                "systray.cpp",
                "systray.h",
                "configuredialogue.cpp",
                "configuredialogue.h",

                "qml/dragtest.qml",
            ]
        }

        Group {     // Properties for the produced executable
            fileTagsFilter: "application"
            qbs.install: true
        }
/*
        // X11/xcb:
        Group {
            name: 'XOrg (BSD/Linux)'
            condition: (!qbs.targetOS.contains("windows"))
            files: ['QHotkey/qhotkey_x11.cpp'];
        }

        Depends {
            name: "Qt.x11extras"
            condition: (!qbs.targetOS.contains("windows"))
        }

        Properties {
            condition: (!qbs.targetOS.contains("windows"))
            cpp.dynamicLibraries: ["X11", "xcb"]
        }

        // Windows:
        Group {
            name: 'Windows'
            condition: (qbs.targetOS.contains("windows"))
            files: ['QHotkey/qhotkey_win.cpp'];
        }
*/
        Properties {
            condition: (qbs.targetOS.contains("windows"))
            cpp.dynamicLibraries: ["user32"]
        }
    }
}
