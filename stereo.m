close all; clear all;

cam1 = ipcam('http://192.168.1.26:8080/video');
cam2 = ipcam('http://192.168.1.22:8080/video'); %Maciej

preview(cam1);
preview(cam2);