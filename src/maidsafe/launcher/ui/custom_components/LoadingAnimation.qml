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

Item {
  id: loadingAnimation
  width: breakingSpriteSequence.width
  height: breakingSpriteSequence.height

  signal finished(bool success)
  signal startFailing() // start showing error message
  readonly property int frameRate: 30

  function showLoading() {
    stopAnimations()
    loadingSpriteSequence.jumpTo("loading")
    loadingSpriteSequence.visible = true
  }
  function showFailed() {
    loadingSprite.to = {"loadingFail":1}
  }
  function showSuccess() {
    loadingSprite.to = {"loadingSuccess":1}
  }
  function stopAnimations() {
    loadingSprite.to = {}
    loadingSpriteSequence.visible = false
    breakingSpriteSequence.visible = false
    breakingSpriteSequence.jumpTo("postBreaking")
  }

  SpriteSequence {
    id: loadingSpriteSequence
    x: 111
    y: 10
    width: 60
    height: 90
    visible: false
    running: visible
    onCurrentSpriteChanged: {
      if (!visible) return;

      if (currentSprite === "postSuccess") {
        finished(true)
      } else if (currentSprite === "failed") {
        loadingSpriteSequence.visible = false
        breakingSpriteSequence.jumpTo("preBreaking")
        breakingSpriteSequence.visible = true
      }
    }

    Sprite {
      id: loadingSprite
      name: "loading"
      source: "/resources/images/loading_sprites.png"
      frameCount: 29
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
      frameRate: loadingAnimation.frameRate
    }

    Sprite {
      name: "loadingFail"
      source: "/resources/images/loading_sprites.png"
      frameX: 9 * frameWidth
      frameY: 2 * frameHeight
      frameCount: 29
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
      frameRate: loadingAnimation.frameRate
      to: {"failed":1}
    }

    Sprite {
      name: "failed"
      source: "/resources/images/loading_sprites.png"
      frameX: 7 * frameWidth
      frameY: 5 * frameHeight
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
    }

    Sprite {
      name: "loadingSuccess"
      source: "/resources/images/loading_sprites.png"
      frameX: 8 * frameWidth
      frameY: 5 * frameHeight
      frameCount: 29
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
      frameRate: loadingAnimation.frameRate
      to: {"success":1}
    }

    Sprite {
      name: "success"
      source: "/resources/images/loading_sprites.png"
      frameX: 6 * frameWidth
      frameY: 8 * frameHeight
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
      frameDuration: 400
      to: {"postSuccess":1}
    }

    Sprite {
      name: "postSuccess"
      source: "/resources/images/loading_sprites.png"
      frameX: 6 * frameWidth
      frameY: 8 * frameHeight
      frameWidth: loadingSpriteSequence.width
      frameHeight: loadingSpriteSequence.height
    }
  }

  SpriteSequence {
    id: breakingSpriteSequence
    width: 280
    height: 100
    visible: false
    running: visible
    onCurrentSpriteChanged: {
      if (!visible) return;

      if (currentSprite === "postBreaking") {
        finished(false)
      } else if (currentSprite === "breaking") {
        startFailing()
      }
    }

    Sprite {
      name: "postBreaking"
      source: "/resources/images/loading_error_sprites.png"
      frameX: 8 * frameWidth
      frameY: 7 * frameHeight
      frameWidth: breakingSpriteSequence.width
      frameHeight: breakingSpriteSequence.height
    }
    Sprite {
      name: "preBreaking"
      source: "/resources/images/loading_error_sprites.png"
      frameWidth: breakingSpriteSequence.width
      frameHeight: breakingSpriteSequence.height
      frameDuration: 600
      to: {"breaking":1}
    }
    Sprite {
      name: "breaking"
      source: "/resources/images/loading_error_sprites.png"
      frameCount: 70
      frameWidth: breakingSpriteSequence.width
      frameHeight: breakingSpriteSequence.height
      frameRate: loadingAnimation.frameRate
      to: {"postBreaking":1}
    }
  }
}

