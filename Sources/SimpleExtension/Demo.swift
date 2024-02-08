//
//  Demo.swift
//
//  Created by Miguel de Icaza on 4/4/23.
//

import Foundation
import SwiftGodot

var sequence = 0

@Godot
class Spinner: Node2D {
    @Export var path: NodePath = .init()

    @Export(.nodeType, "CheckBox")
    var useVariantCheck: CheckBox? = nil

    var sprite: Node2D? = nil
    override func _ready() {
        sprite = getNode(path: path) as? Node2D
    }

    override func _process(delta: Double) {
        guard sprite != nil else {
            return
        }

        guard useVariantCheck != nil else {
            return
        }

        if useVariantCheck!.buttonPressed {
            processWithVariantCheck(delta: delta)
        } else {
            processWithNoCheck(delta: delta)
        }
    }

    func processWithVariantCheck(delta: Double) {
        if GD.isInstanceValid(instance: Variant(sprite!)) {
            sprite?.rotation += delta
        } else {
            GD.printErr("Tried to process, but the variant was not valid")
        }
    }

    func processWithNoCheck(delta: Double) {
        // Crash occurs here, if sprite has been freed but we still have this reference
        sprite?.rotation += delta
    }
}

func setupScene(level: GDExtension.InitializationLevel) {
    if level == .scene {
        register(type: Spinner.self)
    }
}

// Set the swift.gdextension's entry_symbol to "swift_entry_point
@_cdecl("swift_entry_point")
public func swift_entry_point(
    godotGetProcAddr: OpaquePointer?,
    libraryPtr: OpaquePointer?,
    extensionPtr: OpaquePointer?
) -> UInt8 {
    print("SwiftSprite: Starting up")
    guard let godotGetProcAddr, let libraryPtr, let extensionPtr else {
        return 0
    }
    initializeSwiftModule(godotGetProcAddr, libraryPtr, extensionPtr, initHook: setupScene, deInitHook: { _ in })
    return 1
}
