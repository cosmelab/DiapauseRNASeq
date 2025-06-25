# User Rules for AI Assistant Interactions

## 🎯 **Core Principle: Transparency First**

**I must always list ALL changes made to achieve any goal or fix any problem.**

## 📋 **Required Actions for Every Change:**

### 1. **Before Making Changes:**

- ✅ **Ask permission** before creating new files/scripts
- ✅ **Explain what I'm going to change** and why
- ✅ **List all files that will be modified**
- ✅ **Confirm the user wants these changes**

### 2. **When Making Changes:**

- ✅ **List every single file modified**
- ✅ **Show exact changes made** (file names, line numbers, content)
- ✅ **Explain the purpose of each change**
- ✅ **Note any dependencies or side effects**

### 3. **After Making Changes:**

- ✅ **Provide a complete summary** of all modifications
- ✅ **List any new files created**
- ✅ **Note any files deleted or renamed**
- ✅ **Warn about potential impacts** on other scripts/files

## 🚫 **Strict Prohibitions:**

### **Never Change Without Permission:**

- ❌ **Variable names** that other scripts depend on
- ❌ **File names** that are referenced elsewhere
- ❌ **Function names** that are called by other code
- ❌ **Configuration values** without explicit approval
- ❌ **Project structure** without detailed explanation

### **Never Create Without Asking:**

- ❌ **New scripts** unless explicitly requested
- ❌ **New configuration files** without permission
- ❌ **New directories** without approval
- ❌ **Backup files** without notification

## ✅ **Required Communication Format:**

### **Before Changes:**

```
🎯 GOAL: [What we're trying to achieve]
📁 FILES TO MODIFY: [List all files]
🔧 CHANGES NEEDED: [Detailed explanation]
❓ CONFIRMATION: Do you want me to proceed?
```

### **After Changes:**

```
✅ COMPLETED: [What was accomplished]
📝 FILES MODIFIED:
  - file1.py: [specific changes]
  - file2.sh: [specific changes]
📄 NEW FILES:
  - newfile.py: [purpose]
🗑️ DELETED FILES:
  - oldfile.py: [reason]
⚠️ IMPACTS: [Any potential side effects]
```

## 🔍 **Verification Requirements:**

### **Before Proceeding:**

- ✅ **Check for dependencies** on any files I want to change
- ✅ **Search for references** to variable/function names
- ✅ **Verify file paths** are correct
- ✅ **Confirm no conflicts** with existing code

### **After Changes:**

- ✅ **Verify changes work** as intended
- ✅ **Check no breaking changes** to existing functionality
- ✅ **Confirm all dependencies** are still satisfied

## 📚 **Special Rules for This Project:**

### **RNA-seq Analysis Project:**

- ✅ **Preserve data paths** in scripts
- ✅ **Maintain sample naming conventions**
- ✅ **Keep Docker configuration** intact
- ✅ **Respect existing file structure**
- ✅ **Maintain compatibility** with HPC systems

### **Package Management:**

- ✅ **List all packages** being added/removed
- ✅ **Explain why** each change is needed
- ✅ **Verify multi-architecture compatibility**
- ✅ **Check for conflicts** with existing packages

## 🎯 **Example Compliance:**

### **Good Response:**

```
🎯 GOAL: Fix package compatibility issue
📁 FILES TO MODIFY: 
  - Dockerfile (lines 45-50)
  - check_conda_packages.sh (lines 15-20)
🔧 CHANGES NEEDED: Remove unused packages and update package list
❓ CONFIRMATION: Proceed with these changes?

[After changes]
✅ COMPLETED: Fixed package compatibility
📝 FILES MODIFIED:
  - Dockerfile: Removed graphviz, pygraphviz (lines 47-48)
  - check_conda_packages.sh: Updated package list (lines 15-20)
⚠️ IMPACTS: No breaking changes, all dependencies preserved
```

### **Bad Response:**

```
Fixed the issue.
[No details about what was changed]
```

## 🔄 **Update Process:**

- ✅ **This document can be updated** as we discover new requirements
- ✅ **Rules are binding** for all future interactions
- ✅ **User can modify rules** at any time
- ✅ **Changes to rules** must be documented here

---

**Last Updated:** [Current Date]
**Project:** DiapauseRNASeq Analysis
**Purpose:** Ensure transparent, safe, and predictable AI assistance
