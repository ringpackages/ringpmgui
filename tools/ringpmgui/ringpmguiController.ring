# Application : RingPM GUI
# Author      : Ring Community
# Date        : 2025.01.14
# Description : GUI interface for Ring Package Manager

load "ringpmguiView.ring"

if isMainSourceFile() { 
	new qApp
	{
		StyleFusion()
		open_window(:ringpmguiController)
		exec()
	}
}

class ringpmguiController from WindowsControllerParent

	oView = new ringpmguiView

	# Application state
	aInstalledPackages = []
	aInstalledPackagesName = []
	oCurrentProcess = NULL
	
	cPackagesPath = "../ringpm/packages"

	# Load installed packages
	loadInstalledPackages()
		
	# Install a package
	func installPackage
		cPackageName = trim(oView.txtPackageName.text())
		if cPackageName = ""
			showMessage("Please enter a package name to install.")
			return
		ok
		
		executeRingPMCommand("install " + cPackageName)
	
	# Run selected package
	func runPackage
		cPackageName = getSelectedPackageName()
		if cPackageName = ""
			showMessage("Please select a package to run.")
			return
		ok
		
		executeRingPMCommand("run " + cPackageName)
	
	# Update selected package
	func updatePackage
		cPackageName = getSelectedPackageName()
		if cPackageName = ""
			showMessage("Please select a package to update.")
			return
		ok
		
		executeRingPMCommand("update " + cPackageName)
	
	# Remove selected package
	func removePackage
		cPackageName = getSelectedPackageName()
		if cPackageName = ""
			showMessage("Please select a package to remove.")
			return
		ok
		
		# Confirm removal
		nResult = msgBox("Are you sure you want to remove package '" + cPackageName + "'?", 
						"Confirm Removal", 1)  # Yes/No buttons
		if nResult = 1  # Yes button
			executeRingPMCommand("remove " + cPackageName)
		ok

	# Get the name of the currently selected package
	func getSelectedPackageName
		oView {
			nCurrentRow = tblPackages.currentRow()-1
			if nCurrentRow >= 0 and nCurrentRow < len(this.aInstalledPackagesName)
				return this.aInstalledPackagesName[nCurrentRow+1]
			ok
		}
		return ""
	
	# Handle package selection in table
	func packageSelected
		# Enable/disable action buttons based on selection
		bHasSelection = (getSelectedPackageName() != "")
		oView {
			btnRun.setEnabled(bHasSelection)
			btnUpdate.setEnabled(bHasSelection)
			btnRemove.setEnabled(bHasSelection)
		}

	# Execute RingPM command using QProcess
	func executeRingPMCommand cCommand
		oView {
			txtOutput.append("Executing: ringpm " + cCommand + nl)
			txtOutput.append("----------------------------------------" + nl)
		}

		aPara = split(cCommand," ")
		oCommandList = new qStringlist() {
			for cPara in aPara
				append(cPara)
			next
		}

		# Create and configure QProcess
		oCurrentProcess= new qprocess(NULL) {
			setprogram( "ringpm")
			setarguments(oCommandList)
			setReadyReadStandardOutputEvent(Method(:processOutput))
			setReadyReadStandardErrorEvent(Method(:processError))
			start_3( QIODevice_ReadWrite )
		}

		
	# Handle process output
	func processOutput
		if oCurrentProcess != NULL
			cOutput = oCurrentProcess.readAllStandardOutput().data()
			oView.txtOutput.append(cOutput + nl + "Command completed." + nl + nl)
		ok
		# Refresh package list after any command that might change packages
		loadInstalledPackages()
		oCurrentProcess = NULL

	# Handle process errors
	func processError
		if oCurrentProcess != NULL
			cError = oCurrentProcess.readAllStandardError().data()
			oView.txtOutput.append("Error: " + cError)
		ok

	# Load installed packages from packages directory
	func loadInstalledPackages
		aInstalledPackages = []

		try
			# Get all package.ring files in packages directory
			aFiles = []
			if direxists(cPackagesPath)
				aFiles = listAllFiles(cPackagesPath, "ring")
			ok

			# Process each package.ring file
			for cFile in aFiles
				if right(cFile, 12) = "package.ring"
					aPackageInfo = getPackageInfo(cFile)
					if len(aPackageInfo) > 0
						aInstalledPackages + aPackageInfo
					ok
				ok
			next
		catch
			showMessage("Error loading package information.")
		done

		# Update the table
		updatePackageTable()

	# Get package information from package.ring file
	func getPackageInfo cPackageFile
		aPackageInfo = []
		
		try
			cPackageName = split(cPackageFile, "/")[4]
			//cPackagePath = substr(cPackageFile, 1, len(cPackageFile) - 13)
			aInstalledPackagesName + cPackageName

			cContent = read(cPackageFile)
			eval(cContent)

			# Extract package information (assuming aPackageInfo is defined in the file)
			if islocal(:aPackageInfo) and len(aPackageInfo) > 0
				return aPackageInfo
			ok
			
		catch
			# Ignore files that can't be processed
		done

		return []

	# Update the package table with installed packages
	func updatePackageTable
		oView {
			# Clear existing rows
			tblPackages.setRowCount(0)

			# Add packages to table
			for i = 1 to len(this.aInstalledPackages)
				aPackage = this.aInstalledPackages[i]

				# Add row
				tblPackages.setRowCount(i)

				# Set package name
				tblPackages.setItem(i, 1, new QTableWidgetItem(aPackage[:name]))
				
				# Set package description
				tblPackages.setItem(i, 2, new QTableWidgetItem(aPackage[:description]))

				# Set package version
				tblPackages.setItem(i, 3, new QTableWidgetItem(aPackage[:version]))

			next

			# Disable action buttons if no packages
			bHasPackages = (len(this.aInstalledPackages) > 0)
			btnRun.setEnabled(false)
			btnUpdate.setEnabled(false)
			btnRemove.setEnabled(false)
		}

	# Show message to user
	func showMessage cMessage
		msgBox(cMessage, "RingPM GUI", 0)

	# Close application
	func closeApplication
		oView.win.close()

	func msgBox cMessageBoxText, cMessageBoxTitle, nLevel
		oMessageBox = new qmessagebox(oView.win) 
        oMessageBox.setwindowtitle(cMessageBoxTitle)
        oMessageBox.settext(cMessageBoxText )
        if nLevel = 0 oMessageBox.show() ok
        if nLevel = 1
            oMessageBox.setstandardbuttons(QMessageBox_Yes | QMessageBox_No)
            result = oMessageBox.exec()  
			if result = QMessageBox_Yes
					return "1"
			but result = QMessageBox_No
					return "0"	
			ok
		ok
