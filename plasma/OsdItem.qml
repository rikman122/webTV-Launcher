/*
    SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.14
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtra
import QtQuick.Window 2.2

RowLayout {
    // OSD Timeout in msecs - how long it will stay on the screen
    property int timeout: 1800
    // This is either a text or a number, if showingProgress is set to true,
    // the number will be used as a value for the progress bar
    property var osdValue
    // Maximum percent value
    property int osdMaxValue: 100
    // Icon name to display
    property string icon
    // Set to true if the value is meant for progress bar,
    // false for displaying the value as normal text
    property bool showingProgress: false

    spacing: PlasmaCore.Units.smallSpacing

    Layout.preferredWidth: Math.max(Math.min(Screen.desktopAvailableWidth / 2, implicitWidth), PlasmaCore.Units.gridUnit * 15)
    Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
    Layout.minimumWidth: Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumWidth: Layout.preferredWidth
    Layout.maximumHeight: Layout.preferredHeight
    width: Layout.preferredWidth
    height: Layout.preferredHeight

    /*
    PlasmaCore.IconItem {
        Layout.leftMargin: PlasmaCore.Units.smallSpacing
        Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
        Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
        Layout.alignment: Qt.AlignVCenter
        source: icon
        visible: valid
    }
    */
    PlasmaComponents3.ProgressBar {
        id: progressBar
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        // So it never exceeds the minimum popup size
        Layout.minimumWidth: 0
        //Layout.rightMargin: PlasmaCore.Units.smallSpacing
        Layout.rightMargin: 10
        Layout.leftMargin: 10
        visible: showingProgress
        from: 0
        to: osdMaxValue
        value: Number(osdValue)
    }

    // Get the width of a three-digit number so we can size the label
    // to the maximum width to avoid the progress bad resizing itself
    TextMetrics {
        id: widestLabelSize
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "100%")
        font: percentageLabel.font
    }

    /*
    // Numerical display of progress bar value
    PlasmaExtra.Heading {
        id: percentageLabel
        Layout.fillHeight: true
        Layout.preferredWidth: widestLabelSize.width
        Layout.rightMargin: PlasmaCore.Units.smallSpacing
        Layout.alignment: Qt.AlignVCenter
        level: 3
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Percentage value", "%1%", progressBar.value)
        visible: showingProgress
        // Display a subtle visual indication that the volume might be
        // dangerously high
        // ------------------------------------------------
        // Keep this in sync with the copies in plasma-pa:ListItemBase.qml
        // and plasma-pa:VolumeSlider.qml
        color: {
            if (progressBar.value <= 100) {
                return PlasmaCore.Theme.textColor
            } else if (progressBar.value > 100 && progressBar.value <= 125) {
                return PlasmaCore.Theme.neutralTextColor
            } else {
                return PlasmaCore.Theme.negativeTextColor
            }
        }
    }*/

    PlasmaExtra.Heading {
        id: label
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.rightMargin: PlasmaCore.Units.smallSpacing
        Layout.alignment: Qt.AlignVCenter
        level: 3
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: !showingProgress && osdValue ? osdValue : ""
        visible: !showingProgress
    }
}
