import fnmatch

print([v for v in ['v1.1.1b1', 'v1.1.1b2', 'v11.11.11b2', 'v1.1.2', 'v1.11.11', 'v11.11.0'] if fnmatch.fnmatch(v, 'v!(*b*)')])
