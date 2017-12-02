#!/usr/bin/env python3

from select import select
import os
import subprocess
import re


# wait for mpd volume changes and then set the
# master volume in pulse accordingly.
# this is only useful, if mpd's output mixer_type is set to
# 'null'.

# see:
# https://github.com/Mic92/python-mpd2/blob/master/examples/idle.py
# https://www.musicpd.org/doc/user/config_audio_outputs.html

def readStdout(command):
    """ execute the given command and return its stdout """
    proc = subprocess.Popen(command, stdout=subprocess.PIPE)
    proc.wait()
    return proc.stdout.read().decode()

class MPD2PulseAudio:
    def __init__(self):
        self.mpd_volume = -1
        self.pa_volume = -1
        env = os.environ
        env['LC_ALL'] = 'C'
        self.mpc = subprocess.Popen('mpc idleloop mixer'.split(' '), \
            bufsize=1, stdout=subprocess.PIPE)
        self.pactl = subprocess.Popen('pactl subscribe'.split(' '), \
            bufsize=1, env=env, stdout=subprocess.PIPE)

    @staticmethod
    def readline(stream):
        """read a line from the given stream or raise EOF otherwise"""
        raw_line = stream.readline()
        if raw_line == b'':
            raise EOFError
        return raw_line.decode().rstrip()

    def get_mpd_volume(self):
        volume_re = re.compile('volume:[ ]*([0-9]*)%')
        m = volume_re.match(readStdout(['mpc', 'volume']))
        if m:
            if self.mpd_volume != int(m.group(1)):
                self.mpd_volume = int(m.group(1))
                return True
        return False

    def set_mpd_volume(self, vol):
        if vol != self.mpd_volume:
            self.mpd_volume = vol
            subprocess.call(['mpc', '-q', 'volume', str(vol)])

    def get_pa_volume(self):
        volume = readStdout(['ponymix', 'get-volume'])
        if self.pa_volume != int(volume):
            self.pa_volume = int(volume)
            return True
        return False

    def set_pa_volume(self, vol):
        if vol != self.pa_volume:
            self.pa_volume = vol
            subprocess.call(['ponymix', 'set-volume', str(vol) + '%'], \
                stdout=subprocess.PIPE)

    def loop(self):
        self.get_mpd_volume()
        self.get_pa_volume()
        pa_event_re = re.compile('Event \'change\' on sink #[0-9]*')
        while True:
            print("mpd: %d%%, pa: %d%%" % (self.mpd_volume,self.pa_volume))
            ready = select([self.mpc.stdout, self.pactl.stdout], [], [])[0]
            if self.pactl.returncode != None or self.mpc.returncode != None:
                break
            if self.pactl.stdout in ready:
                line = MPD2PulseAudio.readline(self.pactl.stdout)
                m = pa_event_re.match(line)
                if m:
                    if self.get_pa_volume():
                        print("PA %d%% --> MPD" % (self.pa_volume))
                        self.set_mpd_volume(self.pa_volume)
                # print("PA: >{}<" .format(line))
            if self.mpc.stdout in ready:
                line = MPD2PulseAudio.readline(self.mpc.stdout)
                if line == 'mixer':
                    if self.get_mpd_volume():
                        print("MPD %d%% --> PA" % (self.mpd_volume))
                        self.set_pa_volume(self.mpd_volume)
                #print("MPD: >{}<" .format(line))

    def shutdown(self):
        self.pactl.kill()
        self.mpc.kill()
        self.pactl.wait()
        self.mpc.wait()

main = MPD2PulseAudio()
main.loop()
main.shutdown()

