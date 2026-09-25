import sys
import os
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout,
                             QHBoxLayout, QPushButton, QTextEdit, QLineEdit,
                             QLabel, QGroupBox, QCheckBox, QFileDialog, QSplitter,
                             QMenuBar, QTabWidget, QMessageBox, QTreeWidget, QTreeWidgetItem,
                             QStatusBar)
from PyQt6.QtGui import QAction, QIcon, QSyntaxHighlighter, QTextCharFormat, QColor
from PyQt6.QtCore import QProcess, QDateTime, Qt, QRegularExpression
SCRIPT_FOLDER = os.path.dirname(os.path.abspath(__file__))
GLOBAL_QSS = """
QMainWindow{background-color:#f0f0f0;color:#000000;}
QWidget{color:#000000;}
QGroupBox{
    font-weight:bold;
    color:#000000;
    border:1px solid #808080;
    border-radius:2px;
    margin-top:6px;
}
QGroupBox::title{subcontrol-origin:margin;subcontrol-position:top left;padding:1px 6px;}
QPushButton{
    color:#000000;
    background: qlineargradient(x1:0,y1:0,x2:0,y2:1,stop:0 #ffffff, stop:1 #d0d0d0);
    border:1px solid #666666;
    border-radius:2px;
    padding:3px 6px;
}
QPushButton:hover{
    background: qlineargradient(x1:0,y1:0,x2:0,y2:1,stop:0 #e4edf7, stop:1 #b8c8dc);
    border:1px solid #335588;
}
QPushButton:pressed{
    background: qlineargradient(x1:0,y1:0,x2:0,y2:1,stop:0 #b8b8b8, stop:1 #989898);
    border:1px solid #222222;
}
QPushButton:disabled{
    background:#cccccc;
    border:1px solid #888888;
}
QLineEdit{
    color:#000000;
    background:#ffffff;
    border:1px solid #666666;
    border-radius:2px;
    padding:3px;
}
QLabel{
    color:#000000;
}
QCheckBox{
    color:#000000;
}
QMenuBar{
    color:#000000;
    background-color:#f0f0f0;
    border-bottom:1px solid #888888;
}
QMenuBar::item{
    color:#000000;
    background-color:transparent;
}
QMenuBar::item:selected{
    color:#000000;
    background-color:#b0c4de;
}
QMenu{
    color:#000000;
    background-color:#ffffff;
    border:1px solid #666666;
}
QMenu::item{
    color:#000000;
    background-color:transparent;
}
QMenu::item:selected{
    color:#000000;
    background-color:#b0c4de;
}
#codeEditor{
    background:#ffffff;
    color:#000000;
    font-family:"Courier New","Menlo","Monaco",monospace;
    font-size:11pt;
    border:1px solid #666666;
}
#lineNumberArea{
    background:#e0e0e0;
    color:#444444;
    font-family:"Courier New","Menlo","Monaco",monospace;
    font-size:11pt;
    border-right:1px solid #888888;
}
#logOutput{
    background:#000000;
    color:#00ff00;
    font-family:"Courier New","Menlo",monospace;
    font-size:10pt;
    border:1px solid #444444;
}
QTreeWidget{background:#ffffff;border:1px solid #999;}
QTabWidget::pane{border:1px solid #888;}
QTabBar::tab{padding:4px 8px;border:1px solid #aaa;background:#e8e8e8;}
QTabBar::tab:selected{background:#ffffff;border-bottom-color:#ffffff;}
"""
class CppHighlighter(QSyntaxHighlighter):
    def __init__(self, parent=None):
        super().__init__(parent)
        keyword_format = QTextCharFormat()
        keyword_format.setForeground(QColor("#0000ff"))
        keywords = [
            "int", "char", "bool", "double", "long", "long long", "string",
            "if", "else", "for", "while", "do", "return", "include",
            "using", "namespace", "std", "cout", "cin", "getline"
        ]
        self.rules = []
        for word in keywords:
            pattern = QRegularExpression(r"\b" + word + r"\b")
            self.rules.append((pattern, keyword_format))
        preprocessor_format = QTextCharFormat()
        preprocessor_format.setForeground(QColor("#a020f0"))
        self.rules.append((QRegularExpression(r"#\w+"), preprocessor_format))
        string_format = QTextCharFormat()
        string_format.setForeground(QColor("#008000"))
        self.rules.append((QRegularExpression(r'"[^"]*"'), string_format))
        self.rules.append((QRegularExpression(r"'[^']'"), string_format))
        comment_format = QTextCharFormat()
        comment_format.setForeground(QColor("#808080"))
        self.rules.append((QRegularExpression(r"//.*"), comment_format))
    def highlightBlock(self, text):
        for expr, fmt in self.rules:
            match_iter = expr.globalMatch(text)
            while match_iter.hasNext():
                match = match_iter.next()
                self.setFormat(match.capturedStart(), match.capturedLength(), fmt)
class TabEditorContainer(QWidget):
    def __init__(self):
        super().__init__()
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0,0,0,0)
        self.line_num_widget = QTextEdit()
        self.line_num_widget.setObjectName("lineNumberArea")
        self.line_num_widget.setReadOnly(True)
        self.line_num_widget.setFixedWidth(42)
        self.line_num_widget.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.code_editor = QTextEdit()
        self.code_editor.setObjectName("codeEditor")
        self.highlighter = CppHighlighter(self.code_editor.document())
        self.code_editor.textChanged.connect(self.sync_line_number)
        layout.addWidget(self.line_num_widget)
        layout.addWidget(self.code_editor)
    def sync_line_number(self):
        line_count = self.code_editor.document().blockCount()
        line_text = "\n".join(str(i) for i in range(1, line_count+1))
        self.line_num_widget.setPlainText(line_text)
class MacDevCppWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("未命名1 - Dev-C++ 5.11")
        self.resize(1280,860)
        icon_mac = os.path.join(SCRIPT_FOLDER,"icon.icns")
        icon_win = os.path.join(SCRIPT_FOLDER,"icon.ico")
        if sys.platform == "darwin" and os.path.exists(icon_mac):
            self.setWindowIcon(QIcon(icon_mac))
        elif sys.platform == "win32" and os.path.exists(icon_win):
            self.setWindowIcon(QIcon(icon_win))
        self.busy = False
        self.tab_counter = 1
        self.tab_meta = dict()
        menubar: QMenuBar = self.menuBar()
        menu_file = menubar.addMenu("文件(&F)")
        menu_edit = menubar.addMenu("编辑(&E)")
        menu_search = menubar.addMenu("搜索(&S)")
        menu_view = menubar.addMenu("视图(&V)")
        menu_project = menubar.addMenu("项目(&P)")
        menu_run = menubar.addMenu("运行(&R)")
        menu_tool = menubar.addMenu("工具(&T)")
        menu_astyle = menubar.addMenu("AStyle")
        menu_win = menubar.addMenu("窗口(&W)")
        menu_help = menubar.addMenu("帮助(&H)")
        act_new = QAction("新建",self)
        act_open = QAction("打开...",self)
        act_save = QAction("保存",self)
        act_saveall = QAction("全部保存",self)
        act_print = QAction("打印",self)
        menu_file.addAction(act_new)
        menu_file.addAction(act_open)
        menu_file.addAction(act_save)
        menu_file.addAction(act_saveall)
        menu_file.addSeparator()
        menu_file.addAction(act_print)
        act_new.triggered.connect(self.new_file)
        act_open.triggered.connect(self.select_source_file)
        act_save.triggered.connect(self.save_file)
        act_undo = QAction("撤销",self)
        act_redo = QAction("重做",self)
        act_cut = QAction("剪切",self)
        act_copy = QAction("复制",self)
        act_paste = QAction("粘贴",self)
        menu_edit.addAction(act_undo)
        menu_edit.addAction(act_redo)
        menu_edit.addSeparator()
        menu_edit.addAction(act_cut)
        menu_edit.addAction(act_copy)
        menu_edit.addAction(act_paste)
        act_undo.triggered.connect(self.undo_edit)
        act_redo.triggered.connect(self.redo_edit)
        act_cut.triggered.connect(self.cut_text)
        act_copy.triggered.connect(self.copy_text)
        act_paste.triggered.connect(self.paste_text)
        act_find = QAction("查找",self)
        act_replace = QAction("替换",self)
        act_findnext = QAction("查找下一个",self)
        menu_search.addAction(act_find)
        menu_search.addAction(act_replace)
        menu_search.addAction(act_findnext)
        self.act_compile = QAction("编译",self)
        self.act_run = QAction("运行",self)
        self.act_comp_run = QAction("编译运行",self)
        menu_run.addAction(self.act_compile)
        menu_run.addAction(self.act_run)
        menu_run.addAction(self.act_comp_run)
        self.act_compile.triggered.connect(self.call_fast_compile)
        self.act_run.triggered.connect(self.call_run_only)
        self.act_comp_run.triggered.connect(self.call_compile_run)
        self.act_format = QAction("代码格式化", self)
        menu_astyle.addAction(self.act_format)
        self.act_format.triggered.connect(self.call_format)
        tool_bar_widget = QWidget()
        tool_layout = QHBoxLayout(tool_bar_widget)
        tool_layout.setContentsMargins(2,2,2,2)
        tool_layout.setSpacing(3)
        self.btn_new = QPushButton("新建")
        self.btn_open = QPushButton("打开")
        self.btn_save = QPushButton("保存")
        self.btn_save_all = QPushButton("全部保存")
        self.btn_print = QPushButton("打印")
        self.btn_undo = QPushButton("撤销")
        self.btn_redo = QPushButton("重做")
        self.btn_cut = QPushButton("剪切")
        self.btn_copy = QPushButton("复制")
        self.btn_paste = QPushButton("粘贴")
        self.btn_find = QPushButton("查找")
        self.btn_replace = QPushButton("替换")
        self.btn_find_next = QPushButton("查找下一个")
        self.btn_astyle = QPushButton("AStyle")
        self.btn_compile = QPushButton("编译")
        self.btn_run = QPushButton("运行")
        self.btn_compile_run = QPushButton("编译运行")
        self.btn_new.clicked.connect(self.new_file)
        self.btn_open.clicked.connect(self.select_source_file)
        self.btn_save.clicked.connect(self.save_file)
        self.btn_undo.clicked.connect(self.undo_edit)
        self.btn_redo.clicked.connect(self.redo_edit)
        self.btn_cut.clicked.connect(self.cut_text)
        self.btn_copy.clicked.connect(self.copy_text)
        self.btn_paste.clicked.connect(self.paste_text)
        self.btn_astyle.clicked.connect(self.call_format)
        self.btn_compile.clicked.connect(self.call_fast_compile)
        self.btn_run.clicked.connect(self.call_run_only)
        self.btn_compile_run.clicked.connect(self.call_compile_run)
        tool_layout.addWidget(self.btn_new)
        tool_layout.addWidget(self.btn_open)
        tool_layout.addWidget(self.btn_save)
        tool_layout.addWidget(self.btn_save_all)
        tool_layout.addWidget(self.btn_print)
        tool_layout.addSpacing(8)
        tool_layout.addWidget(self.btn_undo)
        tool_layout.addWidget(self.btn_redo)
        tool_layout.addSpacing(8)
        tool_layout.addWidget(self.btn_cut)
        tool_layout.addWidget(self.btn_copy)
        tool_layout.addWidget(self.btn_paste)
        tool_layout.addSpacing(8)
        tool_layout.addWidget(self.btn_find)
        tool_layout.addWidget(self.btn_replace)
        tool_layout.addWidget(self.btn_find_next)
        tool_layout.addSpacing(8)
        tool_layout.addWidget(self.btn_astyle)
        tool_layout.addSpacing(8)
        tool_layout.addWidget(self.btn_compile)
        tool_layout.addWidget(self.btn_run)
        tool_layout.addWidget(self.btn_compile_run)
        tool_layout.addStretch()
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setSpacing(4)
        main_layout.setContentsMargins(4,4,4,4)
        main_layout.addWidget(tool_bar_widget)
        h_splitter = QSplitter(Qt.Orientation.Horizontal)
        self.project_tree = QTreeWidget()
        self.project_tree.setHeaderLabels(["项目管理"])
        item_project = QTreeWidgetItem(["项目"])
        item_globals = QTreeWidgetItem(["(globals)"])
        item_project.addChild(item_globals)
        self.project_tree.addTopLevelItem(item_project)
        self.project_tree.setFixedWidth(180)
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabsClosable(True)
        self.tab_widget.tabCloseRequested.connect(self.close_tab)
        self.tab_widget.currentChanged.connect(self.on_tab_switch)
        h_splitter.addWidget(self.project_tree)
        h_splitter.addWidget(self.tab_widget)
        h_splitter.setStretchFactor(1,3)
        bottom_tabs = QTabWidget()
        self.log_text = QTextEdit()
        self.log_text.setObjectName("logOutput")
        self.log_text.setReadOnly(True)
        bottom_tabs.addTab(self.log_text, "编译器")
        bottom_tabs.addTab(QWidget(), "资源")
        bottom_tabs.addTab(QWidget(), "编译日志")
        bottom_tabs.addTab(QWidget(), "调试")
        bottom_tabs.addTab(QWidget(), "搜索结果")
        v_splitter = QSplitter(Qt.Orientation.Vertical)
        v_splitter.addWidget(h_splitter)
        v_splitter.addWidget(bottom_tabs)
        v_splitter.setStretchFactor(0,3)
        v_splitter.setStretchFactor(1,1)
        main_layout.addWidget(v_splitter)
        self.statusbar = QStatusBar()
        self.setStatusBar(self.statusbar)
        self.status_label_pos = QLabel("行: 1, 列: 1")
        self.status_label_sel = QLabel("已选择:0")
        self.status_label_len = QLabel("长度:0")
        self.status_label_mode = QLabel("插入")
        self.statusbar.addPermanentWidget(self.status_label_pos)
        self.statusbar.addPermanentWidget(self.status_label_sel)
        self.statusbar.addPermanentWidget(self.status_label_len)
        self.statusbar.addPermanentWidget(self.status_label_mode)
        self.shell_proc = QProcess()
        self.shell_proc.readyReadStandardOutput.connect(self.read_stdout)
        self.shell_proc.readyReadStandardError.connect(self.read_stderr)
        self.shell_proc.finished.connect(self.on_process_finished)
        self.new_file()
    def undo_edit(self):
        cur = self.get_current_tab_info()
        if cur: cur["container"].code_editor.undo()
    def redo_edit(self):
        cur = self.get_current_tab_info()
        if cur: cur["container"].code_editor.redo()
    def cut_text(self):
        cur = self.get_current_tab_info()
        if cur: cur["container"].code_editor.cut()
    def copy_text(self):
        cur = self.get_current_tab_info()
        if cur: cur["container"].code_editor.copy()
    def paste_text(self):
        cur = self.get_current_tab_info()
        if cur: cur["container"].code_editor.paste()
    def get_current_tab_info(self):
        idx = self.tab_widget.currentIndex()
        if idx in self.tab_meta:
            return self.tab_meta[idx]
        return None
    def on_tab_switch(self):
        meta = self.get_current_tab_info()
        if meta:
            if meta["file_path"]:
                self.setWindowTitle(f"{os.path.basename(meta['file_path'])} - Dev-C++ 5.11")
            else:
                self.setWindowTitle(f"未命名{self.tab_counter-1} - Dev-C++ 5.11")
    def close_tab(self, index):
        if index in self.tab_meta:
            del self.tab_meta[index]
        self.tab_widget.removeTab(index)
    def log_print(self, text: str):
        timestamp = QDateTime.currentDateTime().toString("hh:mm:ss")
        display_text = text
        display_text = display_text.replace("⚠️","Warning:")
        display_text = display_text.replace("❌","Error:")
        display_text = display_text.replace("✅","Done:")
        display_text = display_text.replace("📄","NewFile:")
        display_text = display_text.replace("📂","OpenFile:")
        display_text = display_text.replace("💾","SaveFile:")
        display_text = display_text.replace("▶️","Info:")
        if "【错误输出】" in display_text or display_text.startswith("Error:"):
            html = f'<span style="color:#ff4444">[{timestamp}] {display_text}</span>'
        elif display_text.startswith("Warning:"):
            html = f'<span style="color:#ffff44">[{timestamp}] {display_text}</span>'
        elif display_text.startswith("Done:"):
            html = f'<span style="color:#44ff44">[{timestamp}] {display_text}</span>'
        else:
            html = f'<span style="color:#00ff00">[{timestamp}] {display_text}</span>'
        self.log_text.append(html)
    def read_stdout(self):
        out = self.shell_proc.readAllStandardOutput().data().decode("utf-8", errors="ignore")
        text = out.rstrip('\n')
        self.log_print(text)
    def read_stderr(self):
        err = self.shell_proc.readAllStandardError().data().decode("utf-8", errors="ignore")
        text = err.rstrip('\n')
        self.log_print(f"【错误输出】{text}")
    def set_all_action_state(self, enable: bool):
        self.btn_compile.setEnabled(enable)
        self.btn_run.setEnabled(enable)
        self.btn_compile_run.setEnabled(enable)
    def start_shell_task(self, args: list):
        if self.busy:
            self.log_print("Warning: Task is running,please wait complete.")
            return False
        control_script = os.path.join(SCRIPT_FOLDER, "control.command")
        if not os.path.exists(control_script):
            self.log_print(f"Error: control.command not found in {SCRIPT_FOLDER}")
            return False
        self.busy = True
        self.set_all_action_state(False)
        self.shell_proc.start(control_script, args)
        return True
    def on_process_finished(self, exit_code, exit_status):
        self.busy = False
        self.set_all_action_state(True)
        self.log_print(f"Done: Task finished, exit code：{exit_code}")
    def new_file(self):
        container = TabEditorContainer()
        tab_name = f"未命名{self.tab_counter}"
        self.tab_counter +=1
        tab_idx = self.tab_widget.addTab(container, tab_name)
        self.tab_meta[tab_idx] = {"container":container, "file_path":""}
        self.tab_widget.setCurrentIndex(tab_idx)
        self.setWindowTitle(f"{tab_name} - Dev-C++ 5.11")
        self.log_print("NewFile: Create blank document,write in editor")
    def select_source_file(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "选择C/C++源码",
            "",
            "C++源文件 (*.cpp);;C文件 (*.c);;头文件 (*.h *.hpp);;所有文件 (*)"
        )
        if file_path:
            open_script = os.path.join(SCRIPT_FOLDER,"open.command")
            content = ""
            if os.path.exists(open_script):
                from PyQt6.QtCore import QProcess
                temp_proc = QProcess()
                temp_proc.start(open_script,[file_path])
                temp_proc.waitForFinished()
                content = temp_proc.readAllStandardOutput().data().decode("utf-8","ignore")
            container = TabEditorContainer()
            container.code_editor.setPlainText(content)
            tab_name = os.path.basename(file_path)
            tab_idx = self.tab_widget.addTab(container, tab_name)
            self.tab_meta[tab_idx] = {"container":container,"file_path":file_path}
            self.tab_widget.setCurrentIndex(tab_idx)
            self.setWindowTitle(f"{tab_name} - Dev-C++ 5.11")
            self.log_print(f"Done: Load source file：{file_path}")
    def save_file(self):
        meta = self.get_current_tab_info()
        if not meta:
            return
        file_path = meta["file_path"]
        container = meta["container"]
        if not file_path:
            save_path, _ = QFileDialog.getSaveFileName(
                self,
                "保存文件",
                "",
                "C++源文件 (*.cpp);;C源文件 (*.c);;头文件 (*.h *.hpp)",
                options=QFileDialog.Option.DontConfirmOverwrite
            )
            if not save_path:
                return
            valid_ext = {".cpp", ".c", ".h", ".hpp"}
            base, ext = os.path.splitext(save_path)
            if ext.lower() not in valid_ext:
                save_path += ".cpp"
            if os.path.exists(save_path):
                reply = QMessageBox.question(self, "文件已存在",
                                             f"文件 {os.path.basename(save_path)} 已经存在，确定要覆盖吗？",
                                             QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
                if reply != QMessageBox.StandardButton.Yes:
                    self.log_print("Info: Save cancelled by user.")
                    return
            write_script = os.path.join(SCRIPT_FOLDER,"write.command")
            if os.path.exists(write_script):
                from PyQt6.QtCore import QProcess
                temp_proc = QProcess()
                temp_proc.start(write_script,[save_path])
                temp_proc.waitForFinished()
            file_path = save_path
            meta["file_path"] = file_path
            idx = self.tab_widget.currentIndex()
            self.tab_widget.setTabText(idx, os.path.basename(file_path))
        try:
            with open(file_path,"w",encoding="utf-8") as f:
                f.write(container.code_editor.toPlainText())
            self.setWindowTitle(f"{os.path.basename(file_path)} - Dev-C++ 5.11")
            self.log_print(f"SaveFile: File saved：{file_path}")
        except Exception as e:
            self.log_print(f"Error: Save failed：{str(e)}")
    def call_run_only(self):
        meta = self.get_current_tab_info()
        if not meta or not meta["file_path"] or not os.path.exists(meta["file_path"]):
            self.log_print("Warning: Please save source file first!")
            return
        self.start_shell_task(["run_only", meta["file_path"]])
        self.log_print("Info: Start run executable file by out.command")
    def call_compile_run(self):
        meta = self.get_current_tab_info()
        if not meta or not meta["file_path"] or not os.path.exists(meta["file_path"]):
            self.log_print("Warning: Please save source file first!")
            return
        self.start_shell_task(["compile_run", meta["file_path"]])
        self.log_print("Info: Start compile and run,will invoke out.command after compile success")
    def call_fast_compile(self):
        meta = self.get_current_tab_info()
        if not meta or not meta["file_path"] or not os.path.exists(meta["file_path"]):
            self.log_print("Warning: Please save source file first!")
            return
        self.start_shell_task(["compile", meta["file_path"]])
        self.log_print("Info: Launch fast compile……")
    def call_format(self):
        meta = self.get_current_tab_info()
        if not meta or not meta["file_path"] or not os.path.exists(meta["file_path"]):
            self.log_print("Warning: Please save source file first!")
            return
        self.start_shell_task(["format", meta["file_path"]])
        self.log_print("Info: Execute code format")
if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyleSheet(GLOBAL_QSS)
    win = MacDevCppWindow()
    win.show()
    sys.exit(app.exec())
