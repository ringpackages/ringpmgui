# Form/Window View - RingPM GUI
# Generated for Ring Package Manager GUI
# Date : 2025.01.14

Load "stdlibcore.ring"
Load "guilib.ring"

import System.GUI

if IsMainSourceFile() { 
	new App {
		StyleFusion()
		new ringpmguiView { win.show() } 
		exec()
	}
}

class ringpmguiView from WindowsViewParent
	win = new MainWindow() { 
		move(100,5)
		resize(900,700)
		setWindowTitle("RingPM GUI - Ring Package Manager")
		setstylesheet("background-color: #f0f0f0;") 

		# Package installation section
		lblPackage = new label(win) {
			move(20,20)
			resize(80,30)
			setstylesheet("color: black; font-weight: bold;")
			setText("Package:")
			setAlignment(Qt_AlignLeft | Qt_AlignVCenter)
		}
		
		txtPackageName = new lineedit(win) {
			move(110,20)
			resize(600,30)
			setstylesheet("color: black; background-color: white; border: 1px solid #ccc; padding: 5px;")
			setPlaceholderText("Enter package name to install...")
			# Package name textbox - Enter key
			setReturnPressedEvent(Method(:installPackage))
		}
		
		btnInstall = new pushbutton(win) {
			move(720,20)
			resize(100,30)
			setstylesheet("background-color: #4CAF50; color: white; border: none; border-radius: 10px; padding: 5px; font-weight: bold; font-size: 14px;")
			setText("Install")
			setClickEvent(Method(:installPackage))
		}
		
		# Installed packages table
		lblInstalledPackages = new label(win) {
			move(20,70)
			resize(200,30)
			setstylesheet("color: black; font-weight: bold; font-size: 14px;")
			setText("Installed Packages:")
			setAlignment(Qt_AlignLeft | Qt_AlignVCenter)
		}
		
		tblPackages = new tablewidget(win) {
			move(20,110)
			resize(860,300)
			setstylesheet("background-color: white; border: 1px solid #ccc; gridline-color: #ddd;")
			setColumnCount(3)
			setSelectionBehavior(QAbstractItemView_SelectRows)
			setHorizontalHeaderItem(1, new QTableWidgetItem("Package Name"))
            setHorizontalHeaderItem(2, new QTableWidgetItem("Package Description"))
            setHorizontalHeaderItem(3, new QTableWidgetItem("Package Version"))
			
			setAlternatingRowColors(true)
            horizontalHeader().setStyleSheet("color: blue")
            verticalHeader().setStyleSheet("color: green")
			# Table selection
			setItemSelectionChangedEvent(Method(:packageSelected))
			
			# Set column widths
			setColumnWidth(1, 200)
			setColumnWidth(2, 500)
			setColumnWidth(3, 150)
			
			# Make table read-only
			setEditTriggers(QAbstractItemView_NoEditTriggers)
		}
		
		# Action buttons
		btnRun = new pushbutton(win) {
			move(20,430)
			resize(100,35)
			setstylesheet("background-color: #2196F3; color: white; border-radius: 10px; border: none; padding: 5px; font-weight: bold; font-size: 14px;")
			setText("Run")
			setEnabled(false)
			setClickEvent(Method(:runPackage))
		}
		
		btnUpdate = new pushbutton(win) {
			move(140,430)
			resize(100,35)
			setstylesheet("background-color: #FF9800; color: white; border-radius: 10px; border: none; padding: 5px; font-weight: bold; font-size: 14px;")
			setText("Update")
			setEnabled(false)
			setClickEvent(Method(:updatePackage))
		}
		
		btnRemove = new pushbutton(win) {
			move(260,430)
			resize(100,35)
			setstylesheet("background-color: #f44336; color: white; border-radius: 10px; border: none; padding: 5px; font-weight: bold; font-size: 14px;")
			setText("Remove")
			setEnabled(false)
			setClickEvent(Method(:removePackage))
		}
		
		btnClose = new pushbutton(win) {
			move(780,430)
			resize(100,35)
			setstylesheet("background-color: #9E9E9E; color: white; border-radius: 10px; border: none; padding: 5px; font-weight: bold; font-size: 14px;")
			setText("Close")
			setClickEvent(Method(:closeApplication))
		}
		
		# Output section
		lblOutput = new label(win) {
			move(20,485)
			resize(100,30)
			setstylesheet("color: black; font-weight: bold; font-size: 14px;")
			setText("Output:")
			setAlignment(Qt_AlignLeft | Qt_AlignVCenter)
		}
		
		txtOutput = new textedit(win) {
			move(20,520)
			resize(860,150)
			setstylesheet("background-color: #2b2b2b; color: #ffffff; border: 1px solid #ccc; font-family: 'Courier New', monospace; font-size: 14px;")
			setReadOnly(true)
			setText("Welcome to RingPM GUI" + nl + "Ready to manage Ring packages..." + nl + nl)
		}

		Layout1 = new QHBoxLayout() {
			AddWidget(lblPackage)
			AddWidget(txtPackageName)
			AddWidget(btnInstall)
		}

		Layout2 = new QHBoxLayout() {
			AddWidget(tblPackages)
		}

		Layout3 = new QHBoxLayout() {
			AddWidget(btnRun)
			AddWidget(btnUpdate)
			AddWidget(btnRemove)
			AddWidget(btnClose)
		}

		Layout4 = new QHBoxLayout() {
			AddWidget(txtOutput)
		}
		
		LayoutMain = new QVBoxLayout() {
			AddLayout(Layout1)
			AddWidget(lblInstalledPackages)
			AddLayout(Layout2)
			AddLayout(Layout3)
			AddWidget(lblOutput)
			AddLayout(Layout4)
		}

		oMWLayoutWidget = new qWidget() { setLayout(LayoutMain) }
		setCentralWidget(oMWLayoutWidget) 
	}
