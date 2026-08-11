#!/usr/bin/env python3

import sys
from PyQt5.QtWidgets import QMenu, QApplication, QAction
from PyQt5.QtWidgets import QMainWindow, QWidget, QPushButton, QAction
from PyQt5.QtGui import QIcon, QCursor
from PyQt5.QtCore import pyqtSlot

class App(QMenu):
    def __init__(self, menuDesc):
        super().__init__()
        self.title = 'PyQt5 menu - pythonspot.com'
        for t, a in menuDesc:
            print(t)
            item = QAction(t, self)
            self.addAction(item)
        #exitButton = QAction('Exit', self)
        #exitButton.triggered.connect(self.close)
        #self.addAction(exitButton)
        pos = QCursor.pos()
        print(pos)
        action = self.exec(pos)
        if action is not None:
            action.trigger();

class Run():
    def __init__(self, cmd):
        self.cmd = cmd

    def trigger(self):
        print(cmd)


menu = [
    ('Terminal', Run('alacritty')),
    ('qutebrowser', Run('qutebrowser')),
    ('Screen off', Run('xset dpms force off')),
]

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App(menu)

