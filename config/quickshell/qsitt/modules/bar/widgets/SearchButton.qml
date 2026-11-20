import qs.ui.theme
import qs.ui.widgets

QsButton {
    required property var searchService
    required property string outputName

    icon: Icons.search
    variant: QsButton.Ghost
    toolTip: "検索 · Super+D"
    onClicked: {
        if (searchService.visible && searchService.focusedOutputName === outputName)
            searchService.close();
        else
            searchService.openOnOutput(outputName, "all");
    }
}
