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
  id: brushes
  objectName: "brushes"

  readonly property color textWeakPassword: "#c1272d"
  readonly property color textMediumPassword: "#f15a24"
  readonly property color textStrongPassword: "#39b54a"

  readonly property color labelSelected: "#1d6499"
  readonly property color labelNotSelected: "#ceebf4"

  readonly property color buttonDefaultBlue: "#73b2d0"
  readonly property color buttonHoveredBlue: "#add6e6"
  readonly property color buttonPressedBlue: "#add6e6"

  readonly property color textFieldBackground: "#ffffff"
}
