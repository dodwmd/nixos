"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.plugin = exports.details = void 0;

var details = function () { return ({
  name: 'Check if NVIDIA Node',
  description: 'Checks if running on a node with NVIDIA GPU via hardware detection and routes accordingly',
  style: {
    borderColor: 'green',
  },
  tags: 'filter,nvidia,hardware,detection',
  isStartPlugin: false,
  pType: '',
  requiresVersion: '2.00.00',
  sidebarPosition: -1,
  icon: '',
  inputs: [],
  outputs: [
    {
      number: 1,
      tooltip: 'NVIDIA GPU detected',
    },
    {
      number: 2,
      tooltip: 'AMD/Intel GPU (VAAPI) detected',
    },
  ],
}); };
exports.details = details;

var plugin = function (args) {
  var lib = require('../../../../../methods/lib')();
  args.inputs = lib.loadDefaultValues(args.inputs, details);
  var fs = require('fs');
  var execSync = require('child_process').execSync;

  args.jobLog('Detecting GPU hardware...');
  
  // Check for NVIDIA GPU via device files or environment variables
  var hasNVIDIA = false;
  try {
    // Check NVIDIA environment variables (set by CDI)
    var nvidiaVisible = process.env.NVIDIA_VISIBLE_DEVICES;
    var nvidiaCapabilities = process.env.NVIDIA_DRIVER_CAPABILITIES;
    
    args.jobLog('DEBUG: NVIDIA_VISIBLE_DEVICES=' + nvidiaVisible);
    args.jobLog('DEBUG: NVIDIA_DRIVER_CAPABILITIES=' + nvidiaCapabilities);
    args.jobLog('DEBUG: /dev/nvidia0 exists=' + fs.existsSync('/dev/nvidia0'));
    args.jobLog('DEBUG: /dev/nvidiactl exists=' + fs.existsSync('/dev/nvidiactl'));
    
    // Check for NVIDIA device files (must have actual hardware)
    hasNVIDIA = fs.existsSync('/dev/nvidia0') || 
                fs.existsSync('/dev/nvidiactl');
    
    if (hasNVIDIA) {
      args.jobLog('NVIDIA GPU detected (devices or CDI)');
    } else {
      args.jobLog('NVIDIA GPU not detected');
    }
  } catch (e) {
    args.jobLog('Error checking NVIDIA: ' + e.message);
  }
  
  // Check for VAAPI (AMD/Intel)
  var hasVAAPI = false;
  try {
    hasVAAPI = fs.existsSync('/dev/dri/renderD128');
    if (hasVAAPI) {
      args.jobLog('✅ VAAPI device detected (/dev/dri/renderD128)');
    } else {
      args.jobLog('❌ VAAPI device not found');
    }
  } catch (e) {
    args.jobLog('❌ Error checking VAAPI: ' + e.message);
  }
  
  // Route based on hardware priority: NVIDIA > VAAPI
  if (hasNVIDIA) {
    args.jobLog('Routing to NVENC (NVIDIA)');
    return {
      outputFileObj: args.inputFileObj,
      outputNumber: 1,
      variables: args.variables,
    };
  } else if (hasVAAPI) {
    args.jobLog('Routing to VAAPI (AMD/Intel)');
    return {
      outputFileObj: args.inputFileObj,
      outputNumber: 2,
      variables: args.variables,
    };
  } else {
    args.jobLog('No GPU detected, routing to VAAPI fallback');
    return {
      outputFileObj: args.inputFileObj,
      outputNumber: 2,
      variables: args.variables,
    };
  }
};
exports.plugin = plugin;
