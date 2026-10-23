"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.plugin = exports.details = void 0;
/* eslint no-plusplus: ["error", { "allowForLoopAfterthoughts": true }] */
var details = function () { return ({
    name: 'Check if GPU Worker',
    description: 'Checks if this node has any GPU hardware (NVIDIA or VAAPI) available for transcoding',
    style: {
        borderColor: '#6efefc',
    },
    tags: '',
    isStartPlugin: false,
    pType: '',
    requiresVersion: '2.11.01',
    sidebarPosition: -1,
    icon: 'faQuestion',
    inputs: [],
    outputs: [
        {
            number: 1,
            tooltip: 'GPU hardware detected',
        },
        {
            number: 2,
            tooltip: 'No GPU hardware (CPU only)',
        },
    ],
}); };
exports.details = details;
// eslint-disable-next-line @typescript-eslint/no-unused-vars
var plugin = function (args) {
    var lib = require('../../../../../methods/lib')();
    // eslint-disable-next-line @typescript-eslint/no-unused-vars,no-param-reassign
    args.inputs = lib.loadDefaultValues(args.inputs, details);
    var fs = require('fs');
    args.jobLog('Checking for GPU hardware...');
    var hasGPU = false;
    // Check for NVIDIA devices
    try {
        if (fs.existsSync('/dev/nvidia0') || fs.existsSync('/dev/nvidiactl')) {
            args.jobLog('NVIDIA GPU device detected');
            hasGPU = true;
        }
    }
    catch (e) {
        args.jobLog("Error checking NVIDIA: ".concat(e.message));
    }
    // Check for VAAPI devices (AMD/Intel)
    if (!hasGPU) {
        try {
            if (fs.existsSync('/dev/dri/renderD128')) {
                args.jobLog('VAAPI device detected (/dev/dri/renderD128)');
                hasGPU = true;
            }
        }
        catch (e) {
            args.jobLog("Error checking VAAPI: ".concat(e.message));
        }
    }
    if (hasGPU) {
        args.jobLog('Routing to GPU transcode');
        return {
            outputFileObj: args.inputFileObj,
            outputNumber: 1,
            variables: args.variables,
        };
    }
    args.jobLog('No GPU hardware found, routing to CPU transcode');
    return {
        outputFileObj: args.inputFileObj,
        outputNumber: 2,
        variables: args.variables,
    };
};
exports.plugin = plugin;
