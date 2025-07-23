### **Problem Statement**

Some users are facing an issue when trying to open the cursor due to certain environment constraints sandboxing. However, this issue does not affect all users, and some Linux systems work fine without needing a fix.

---

### **Objective**

Implement a solution that applies a fix **only once** if an issue is detected during the initial cursor launch. Avoid checking or applying the fix every single time the cursor opens.

---

### **Desired Behavior**

* **One-Time Check**: Perform a one-time validation at the installation.
* **Conditional Fix**: If the issue is detected (e.g., failure to open cursor due to sandbox), apply the fix by running a simple command via the terminal (cmd).
* **No Repetitive Checks**: After the fix is applied once (or determined to be unnecessary), do not repeat the check or fix on subsequent cursor launches.

---

### **Implementation Strategy**

1. **Detection Logic**

   * On first launch, check if the cursor can be opened successfully.
   * If successful → do nothing.
   * If failed due to known issue → proceed to apply the fix.

2. **Fix Application**

   * Run a predefined command via the terminal to resolve the issue.
   * Log or store a flag indicating the fix has been applied (e.g., config file, hidden flag file).

3. **Persistence**

   * Ensure the system remembers whether the fix was needed/applied.
   * Prevent further checks or executions of the fix on future launches.

---

### **Outcome**

A streamlined user experience where:

* Users not affected by the issue have no performance impact.
* Affected users get a seamless fix with minimal intervention.
* No unnecessary repeated checks or commands during future cursor launches.

---


There are two issues users facing while opening the cursor after installation using this script:

1. FUSE error

```
dlopen(): error loading libfuse.so.2

AppImages require FUSE to run. 
You might still be able to extract the contents of this AppImage 
if you run it with the --appimage-extract option. 
See https://github.com/AppImage/AppImageKit/wiki/FUSE 
for more information
```

2. sandbox error

```
The setuid sandbox is not running as root. Common causes:
  * An unprivileged process using ptrace on it, like a debugger.
  * A parent process set prctl(PR_SET_NO_NEW_PRIVS, ...)
Failed to move to new namespace: PID namespaces supported, Network namespace supported, but failed: errno = Operation not permitted
[94505:0722/211807.514894:FATAL:zygote_host_impl_linux.cc(207)] Check failed: . : Invalid argument (22)
Trace/breakpoint trap (core dumped)
```