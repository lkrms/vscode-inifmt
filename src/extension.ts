import * as vscode from 'vscode'
import * as path from 'path'
import { spawn } from 'child_process'

// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function activate (context: vscode.ExtensionContext) {
  function formatDocument (
    document: vscode.TextDocument
  ): Thenable<vscode.TextEdit[]> {
    return new Promise((resolve) => {
      const text = document.getText()
      const awk = spawn('awk', ['-f', path.resolve(__dirname, '../scripts/inifmt.awk')])

      console.log('Spawned:', ...awk.spawnargs)

      let stdout = ''
      awk.stdout.setEncoding('utf8')
      awk.stdout.on('data', (chunk: string) => { stdout += chunk })

      let stderr = ''
      awk.stderr.setEncoding('utf8')
      awk.stderr.on('data', (chunk: string) => { stderr += chunk })

      awk.on('close', (code: number) => {
        if (code === 0) {
          console.log('%s succeeded (output length: %i)', awk.spawnfile, stdout.length)
          if (stdout.length > 0 && stdout !== text) {
            resolve([new vscode.TextEdit(new vscode.Range(
              document.lineAt(0).range.start,
              document.lineAt(document.lineCount - 1).rangeIncludingLineBreak.end
            ), stdout)])
          } else {
            console.log('Nothing to change')
            resolve([])
          }
        } else {
          console.log('%s failed (exit status: %i)', awk.spawnfile, code)
          console.error(stderr)
          resolve([])
        }
      })

      awk.stdin.write(document.getText())
      awk.stdin.end()
    })
  }

  function handleCommand (): void {
    const document = vscode.window.activeTextEditor?.document
    if (document != null) {
      formatDocument(document)
        .then((edits: vscode.TextEdit[]) => {
          const edit = new vscode.WorkspaceEdit()
          edit.set(document.uri, edits)
          vscode.workspace.applyEdit(edit)
            .then(() => { }, () => { })
        }, () => { })
    }
  }

  vscode.languages.registerDocumentFormattingEditProvider([
    'ini',
    'dotenv',
    'hosts',
    'ignore',
    'plaintext',
    'properties',
    'ssh_config'
  ], {
    provideDocumentFormattingEdits (
      document: vscode.TextDocument
    ): Thenable<vscode.TextEdit[]> {
      return formatDocument(document)
    }
  })

  context.subscriptions.push(
    vscode.commands.registerCommand('inifmt.format', () => handleCommand())
  )
}

// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function deactivate () { }
