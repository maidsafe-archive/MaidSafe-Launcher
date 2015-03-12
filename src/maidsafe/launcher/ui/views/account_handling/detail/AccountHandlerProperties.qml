/*  Copyright 2015 MaidSafe.net limited

    This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,
    version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which
    licence you accepted on initial access to the Software (the "Licences").

    By contributing code to the MaidSafe Software, or to this project generally, you agree to be
    bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root
    directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also
    available at: http://www.maidsafe.net/licenses

    Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed
    under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
    OF ANY KIND, either express or implied.

    See the Licences for the specific language governing permissions and limitations relating to
    use of the MaidSafe Software.                                                                 */

import QtQuick 2.4

QtObject {
  id: properties
  objectName: "properties"

  readonly property int defaultFontPixelSize: 18
  readonly property int customTextPixelSize: 15

  readonly property int cancelButtonWidth: 120
  readonly property int cancelButtonBottom: 125
  readonly property int cancelButtonHeight: 35

  readonly property int textFieldWidth: 320
  readonly property int textFieldHeight: 35
  readonly property int textFieldRadius: 5
  readonly property int textFieldVerticalSpacing: 15

  readonly property int clickableTextBottomMargin: 45

  readonly property int blueButtonWidth: textFieldWidth
  readonly property int blueButtonHeight: textFieldHeight
  readonly property int blueButtonRadius: textFieldRadius
  readonly property int blueButtonMargin: 15
}
