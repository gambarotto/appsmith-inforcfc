const KEYNAV_EN = `<h1>Begin keyboard navigation</h1>

<dl>
  <dt>Focus the Menu bar</dt>
  <dd>Windows or Linux: Alt+F9</dd>
  <dd>macOS: &#x2325;F9</dd>
  <dt>Focus the Toolbar</dt>
  <dd>Windows or Linux: Alt+F10</dd>
  <dd>macOS: &#x2325;F10</dd>
  <dt>Focus the footer</dt>
  <dd>Windows or Linux: Alt+F11</dd>
  <dd>macOS: &#x2325;F11</dd>
  <dt>Focus a contextual toolbar</dt>
  <dd>Windows, Linux or macOS: Ctrl+F9
</dl>

<p>Navigation will start at the first UI item, which will be highlighted, or underlined in the case of the first item in
  the Footer element path.</p>

<h1>Navigate between UI sections</h1>

<p>To move from one UI section to the next, press <strong>Tab</strong>.</p>

<p>To move from one UI section to the previous, press <strong>Shift+Tab</strong>.</p>

<p>The <strong>Tab</strong> order of these UI sections is:</p>

<ol>
  <li>Menu bar</li>
  <li>Each toolbar group</li>
  <li>Sidebar</li>
  <li>Element path in the footer</li>
  <li>Word count toggle button in the footer</li>
  <li>Branding link in the footer</li>
  <li>Editor resize handle in the footer</li>
</ol>

<p>If a UI section is not present, it is skipped.</p>

<p>If the footer has keyboard navigation focus, and there is no visible sidebar, pressing <strong>Shift+Tab</strong>
  moves focus to the first toolbar group, not the last.</p>

<h1>Navigate within UI sections</h1>

<p>To move from one UI element to the next, press the appropriate <strong>Arrow</strong> key.</p>

<p>The <strong>Left</strong> and <strong>Right</strong> arrow keys</p>

<ul>
  <li>move between menus in the menu bar.</li>
  <li>open a sub-menu in a menu.</li>
  <li>move between buttons in a toolbar group.</li>
  <li>move between items in the footer’s element path.</li>
</ul>

<p>The <strong>Down</strong> and <strong>Up</strong> arrow keys</p>

<ul>
  <li>move between menu items in a menu.</li>
  <li>move between items in a toolbar pop-up menu.</li>
</ul>

<p><strong>Arrow</strong> keys cycle within the focused UI section.</p>

<p>To close an open menu, an open sub-menu, or an open pop-up menu, press the <strong>Esc</strong> key.</p>

<p>If the current focus is at the ‘top’ of a particular UI section, pressing the <strong>Esc</strong> key also exits
  keyboard navigation entirely.</p>

<h1>Execute a menu item or toolbar button</h1>

<p>When the desired menu item or toolbar button is highlighted, press <strong>Return</strong>, <strong>Enter</strong>,
  or the <strong>Space bar</strong> to execute the item.</p>

<h1>Navigate non-tabbed dialogs</h1>

<p>In non-tabbed dialogs, the first interactive component takes focus when the dialog opens.</p>

<p>Navigate between interactive dialog components by pressing <strong>Tab</strong> or <strong>Shift+Tab</strong>.</p>

<h1>Navigate tabbed dialogs</h1>

<p>In tabbed dialogs, the first button in the tab menu takes focus when the dialog opens.</p>

<p>Navigate between interactive components of this dialog tab by pressing <strong>Tab</strong> or
  <strong>Shift+Tab</strong>.</p>

<p>Switch to another dialog tab by giving the tab menu focus and then pressing the appropriate <strong>Arrow</strong>
  key to cycle through the available tabs.</p>`;

const KEYNAV_PT_BR = `<h1>Iniciar navegação pelo teclado</h1>

<dl>
  <dt>Foco na barra de menus</dt>
  <dd>Windows ou Linux: Alt+F9</dd>
  <dd>macOS: &#x2325;F9</dd>
  <dt>Foco na barra de ferramentas</dt>
  <dd>Windows ou Linux: Alt+F10</dd>
  <dd>macOS: &#x2325;F10</dd>
  <dt>Foco no rodapé</dt>
  <dd>Windows ou Linux: Alt+F11</dd>
  <dd>macOS: &#x2325;F11</dd>
  <dt>Foco na barra de ferramentas contextual</dt>
  <dd>Windows, Linux ou macOS: Ctrl+F9
</dl>

<p>A navegação inicia no primeiro item da IU, que será destacado ou sublinhado no caso do primeiro item no
  caminho do elemento Rodapé.</p>

<h1>Navegar entre seções da IU</h1>

<p>Para ir de uma seção da IU para a seguinte, pressione <strong>Tab</strong>.</p>

<p>Para ir de uma seção da IU para a anterior, pressione <strong>Shift+Tab</strong>.</p>

<p>A ordem de <strong>Tab</strong> destas seções da IU é:</p>

<ol>
  <li>Barra de menus</li>
  <li>Cada grupo da barra de ferramentas</li>
  <li>Barra lateral</li>
  <li>Caminho do elemento no rodapé</li>
  <li>Botão de alternar contagem de palavras no rodapé</li>
  <li>Link da marca no rodapé</li>
  <li>Alça de redimensionamento do editor no rodapé</li>
</ol>

<p>Se não houver uma seção da IU, ela será pulada.</p>

<p>Se o rodapé tiver o foco da navegação pelo teclado e não houver uma barra lateral visível, pressionar <strong>Shift+Tab</strong>
  move o foco para o primeiro grupo da barra de ferramentas, não para o último.</p>

<h1>Navegar dentro das seções da IU</h1>

<p>Para ir de um elemento da IU para o seguinte, pressione a <strong>Seta</strong> correspondente.</p>

<p>As teclas de seta <strong>Esquerda</strong> e <strong>Direita</strong></p>

<ul>
  <li>movem entre menus na barra de menus.</li>
  <li>abrem um submenu em um menu.</li>
  <li>movem entre botões em um grupo da barra de ferramentas.</li>
  <li>movem entre itens no caminho do elemento do rodapé.</li>
</ul>

<p>As teclas de seta <strong>Abaixo</strong> e <strong>Acima</strong></p>

<ul>
  <li>movem entre itens de menu em um menu.</li>
  <li>movem entre itens em um menu suspenso da barra de ferramentas.</li>
</ul>

<p>As teclas de <strong>Seta</strong> alternam dentre a seção da IU em foco.</p>

<p>Para fechar um menu aberto, um submenu aberto ou um menu suspenso aberto, pressione <strong>Esc</strong>.</p>

<p>Se o foco atual estiver no ‘alto’ de determinada seção da IU, pressionar <strong>Esc</strong> também sai
  totalmente da navegação pelo teclado.</p>

<h1>Executar um item de menu ou botão da barra de ferramentas</h1>

<p>Com o item de menu ou botão da barra de ferramentas desejado destacado, pressione <strong>Return</strong>, <strong>Enter</strong>,
  ou a <strong>Barra de espaço</strong> para executar o item.</p>

<h1>Navegar por caixas de diálogo sem guias</h1>

<p>Em caixas de diálogo sem guias, o primeiro componente interativo recebe o foco quando a caixa de diálogo abre.</p>

<p>Navegue entre componentes interativos de caixa de diálogo pressionando <strong>Tab</strong> ou <strong>Shift+Tab</strong>.</p>

<h1>Navegar por caixas de diálogo com guias</h1>

<p>Em caixas de diálogo com guias, o primeiro botão no menu da guia recebe o foco quando a caixa de diálogo abre.</p>

<p>Navegue entre componentes interativos dessa guia da caixa de diálogo pressionando <strong>Tab</strong> ou
  <strong>Shift+Tab</strong>.</p>

<p>Alterne para outra guia da caixa de diálogo colocando o foco no menu da guia e pressionando a <strong>Seta</strong>
  adequada para percorrer as guias disponíveis.</p>`;

let resourcesRegistered = false;

export function registerHelpKeynavResources() {
  if (resourcesRegistered) return;

  const tinymceGlobal = (window as typeof window & { tinymce?: typeof import("tinymce") }).tinymce;

  if (!tinymceGlobal?.Resource) {
    return;
  }

  tinymceGlobal.Resource.add("tinymce.html-i18n.help-keynav.en", KEYNAV_EN);
  tinymceGlobal.Resource.add("tinymce.html-i18n.help-keynav.pt_BR", KEYNAV_PT_BR);

  resourcesRegistered = true;
}

