/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package ohos.pasteboard

import ohos.business_exception.AsyncCallback
import ohos.labels.*
import ohos.multimedia.image.PixelMap
import std.collection.HashMap

type ArrayBuffer = Array<UInt8>

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public const MIMETYPE_TEXT_HTML: String = "text/html"

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public const MIMETYPE_TEXT_WANT: String = "text/want"

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public const MIMETYPE_TEXT_PLAIN: String = "text/plain"

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public const MIMETYPE_TEXT_URI: String = "text/uri"

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public const MIMETYPE_PIXELMAP: String = "pixelMap"

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public enum PasteDataValueType {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    ArrayBufferValue(ArrayBuffer)
    |
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    PixelMapValue(PixelMap)
    |
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    StringValue(String)
    | ...
}

extend PasteDataValueType <: ToString {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func toString(): String {
        return ""
    }
}

extend PasteDataValueType <: Equatable<PasteDataValueType> {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public operator func ==(other: PasteDataValueType): Bool {
        return true
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public operator func !=(other: PasteDataValueType): Bool {
        return true
    }
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public enum ShareOption {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    Inapp
    |
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    Localdevice
    | ...
}

extend ShareOption <: ToString {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func toString(): String {
        return ""
    }
}

extend ShareOption <: Equatable<ShareOption> {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public operator func ==(other: ShareOption): Bool {
        return true
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public operator func !=(other: ShareOption): Bool {
        return true
    }
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public func createData(mimeType: String, value: PasteDataValueType): PasteData {
    return PasteData()
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public func createData(data: HashMap<String, PasteDataValueType>): PasteData {
    return PasteData()
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public func createRecord(mimeType: String, value: PasteDataValueType): PasteDataRecord {
    return PasteDataRecord()
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public func getSystemPasteboard(): SystemPasteboard {
    return SystemPasteboard()
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public class PasteDataProperty {
    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public prop mimeTypes: Array<String> {
        get() { [] }
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop tag: String {
        get() { "" }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public prop timestamp: Int64 {
        get() { 0 }
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop localOnly: Bool {
        get() { false }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop shareOption: ShareOption {
        get() { Localdevice }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public init(
        mimeTypes: Array<String>,
        tag: String,
        timestamp: Int64,
        localOnly: Bool,
        shareOption: ShareOption
    ) {}
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public class PasteDataRecord {
    internal init() {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop htmlText: String {
        get() { "" }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop mimeType: String {
        get() { "" }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop plainText: String {
        get() { "" }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop uri: String {
        get() { "" }
        set(_) {}
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public mut prop pixelMap: PixelMap {
        get() { PixelMap() }
        set(_) {}
    }
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public class PasteData {
    internal init() {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func addRecord(record: PasteDataRecord): Unit {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func addRecord(mimeType: String, value: PasteDataValueType): Unit {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getMimeTypes(): Array<String> {
        return []
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getPrimaryHtml(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getPrimaryMimeType(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getPrimaryText(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getPrimaryUri(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getPrimaryPixelMap(): PixelMap {
        return PixelMap()
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getProperty(): PasteDataProperty {
        return PasteDataProperty([], "", 0, false, Localdevice)
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func setProperty(pasteDataProperty: PasteDataProperty): Unit {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func getRecord(index: Int32): PasteDataRecord {
        return PasteDataRecord()
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getRecordCount(): UIntNative {
        return 0
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func getTag(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func hasType(mimeType: String): Bool {
        return false
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func removeRecord(index: Int32): Unit {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func replaceRecord(index: Int32, record: PasteDataRecord): Unit {}
}

@!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
public class SystemPasteboard {
    internal init() {}

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func isRemoteData(): Bool {
        return false
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func getDataSource(): String {
        return ""
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func hasDataType(mimeType: String): Bool {
        return false
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func clearData(callback: AsyncCallback<Unit>): Unit {
        callback(None, ())
    }

    @!APILevel[
        since: "26.1.0",
        permission: "ohos.permission.READ_PASTEBOARD",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func getData(callback: AsyncCallback<PasteData>): Unit {
        callback(None, PasteData())
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard"]
    public func hasData(callback: AsyncCallback<Bool>): Unit {
        callback(None, false)
    }

    @!APILevel[since: "26.1.0", syscap: "SystemCapability.MiscServices.Pasteboard", throwexception: true]
    public func setData(data: PasteData, callback: AsyncCallback<Unit>): Unit {
        callback(None, ())
    }
}
