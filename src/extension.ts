import * as vscode from 'vscode';
import * as path from 'path';
import { spawn } from 'child_process';

export function activate(context: vscode.ExtensionContext) {

	function formatDocument(
		document: vscode.TextDocument
	): Thenable<vscode.TextEdit[]> {
		return new Promise((resolve, reject) => {
			const text = document.getText(),
				awk = spawn("awk", ["-f", path.resolve(__dirname, "../scripts/inifmt.awk")]);

			console.log("Spawned:", ...awk.spawnargs);

			let stdout = "";
			awk.stdout.setEncoding("utf8");
			awk.stdout.on("data", (chunk) => stdout += chunk);

			let stderr = "";
			awk.stderr.setEncoding("utf8");
			awk.stderr.on("data", (chunk) => stderr += chunk);

			awk.on("close", (code, signal) => {
				if (code === 0) {
					console.log("%s succeeded (output length: %i)", awk.spawnfile, stdout.length);
					if (stdout.length && stdout !== text) {
						resolve([new vscode.TextEdit(new vscode.Range(
							document.lineAt(0).range.start,
							document.lineAt(document.lineCount - 1).rangeIncludingLineBreak.end
						), stdout)]);
					} else {
						console.log("Nothing to change");
						resolve([]);
					}
				} else {
					console.log("%s failed (exit status: %i)", awk.spawnfile, code);
					console.error(stderr);
					reject(stderr);
				}
			});

			awk.stdin.write(document.getText());
			awk.stdin.end();
		});
	}

	vscode.languages.registerDocumentFormattingEditProvider([
		"ini",
		"dotenv",
		"hosts",
		"ignore",
		"plaintext",
		"properties",
		"ssh_config"
	], {
		provideDocumentFormattingEdits(
			document: vscode.TextDocument,
			options: vscode.FormattingOptions,
			token: vscode.CancellationToken
		): Thenable<vscode.TextEdit[]> {
			return formatDocument(document);
		}
	});

	let formatCommand = vscode.commands.registerCommand('inifmt.format', () => {
		const document = vscode.window.activeTextEditor?.document;
		if (document) {
			formatDocument(document).then((edits: vscode.TextEdit[]) => {
				let edit = new vscode.WorkspaceEdit();
				edit.set(document.uri, edits);
				vscode.workspace.applyEdit(edit);
			});
		}
	});

	context.subscriptions.push(formatCommand);
}

// this method is called when your extension is deactivated
export function deactivate() { }
