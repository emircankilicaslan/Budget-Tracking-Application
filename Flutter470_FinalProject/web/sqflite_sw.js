// This is a minimal implementation of the sqflite web worker
// It's required for sqflite_common_ffi_web to work properly

self.onmessage = function(e) {
  if (e.data && e.data.type === 'init') {
    self.postMessage({ type: 'init', success: true });
  }
}; 