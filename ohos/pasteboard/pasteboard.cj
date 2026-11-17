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

// The Cangjie API is in Beta. For details on its capabilities and limitations, please refer to the README file.

package ohos.pasteboard

import std.deriving.Derive
import ohos.business_exception.{AsyncCallback, BusinessException}
import ohos.ffi.{CArrString, RemoteDataLite, RetDataCArrString, RetDataCString, RetDataI64, SUCCESS_CODE,
    cArr2cjArr, cjArr2CArr, releaseFFIData}
import ohos.labels.APILevel
import ohos.multimedia.image.PixelMap
import std.collection.HashMap

type ArrayBuffer = Array<UInt8>

internal const ERR_CODE_PERMISSION_DENIED: Int32 = 201
internal const ERR_CODE_PARAMETER_ERROR: Int32 = 401
internal const ERR_CODE_INDEX_OUT_OF_RANGE: Int32 = 12900001
internal const ERR_CODE_TIMEOUT: Int32 = 12900005
internal const ERR_CODE_OPERATION_IN_PROGRESS: Int32 = 27787277
internal const ERR_CODE_REPLICATION_PROHIBITED: Int32 = 27787278
internal const ERR_CODE_INVALID_OBJECT: Int32 = -1

internal const SHARE_OPTION_VALUE_INAPP: Int32 = 0
internal const SHARE_OPTION_VALUE_LOCAL_DEVICE: Int32 = 1

/**
 * MIME type of the HTML content.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public const MIMETYPE_TEXT_HTML: String = "text/html"

/**
 * MIME type of the Want content.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public const MIMETYPE_TEXT_WANT: String = "text/want"

/**
 * MIME type of the plain text content.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public const MIMETYPE_TEXT_PLAIN: String = "text/plain"

/**
 * MIME type of the URI content.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public const MIMETYPE_TEXT_URI: String = "text/uri"

/**
 * MIME type of the PixelMap content.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public const MIMETYPE_PIXELMAP: String = "pixelMap"

/**
 * Indicates the type of the value.
 *
 * It is used, for example, as the value parameter of createData, createRecord, and PasteData.addRecord.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public enum PasteDataValueType {
    /**
     * Represents a value of the ArrayBuffer type.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    ArrayBufferValue(ArrayBuffer)
    |
    /**
     * Represents a value of the PixelMap type.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    PixelMapValue(PixelMap)
    |
    /**
     * Represents a value of the String type.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    StringValue(String)
    | ...
}

extend PasteDataValueType <: ToString {
    /**
     * Converts the PasteDataValueType to its string representation.
     * @returns { String } A string representation of the PasteDataValueType.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func toString(): String {
        match (this) {
            case ArrayBufferValue(_) => "ArrayBufferValue"
            case PixelMapValue(_) => "PixelMapValue"
            case StringValue(_) => "StringValue"
            case _ => "Unknown"
        }
    }
}

func arrayBufferEquals(left: Array<UInt8>, right: Array<UInt8>): Bool {
    if (left.size != right.size) {
        return false
    }
    for (i in 0..left.size) {
        if (left[i] != right[i]) {
            return false
        }
    }
    return true
}

extend PasteDataValueType <: Equatable<PasteDataValueType> {
    /**
     * Compares this PasteDataValueType with another for equality.
     * @param { PasteDataValueType } other - The PasteDataValueType to compare with.
     * @returns { Bool } True if both values are equal, false otherwise.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public operator func ==(other: PasteDataValueType): Bool {
        match ((this, other)) {
            case (ArrayBufferValue(left), ArrayBufferValue(right)) => arrayBufferEquals(left, right)
            case (PixelMapValue(left), PixelMapValue(right)) => left.getID() == right.getID()
            case (StringValue(left), StringValue(right)) => left == right
            case _ => false
        }
    }
    /**
     * Compares this PasteDataValueType with another for inequality.
     * @param { PasteDataValueType } other - The PasteDataValueType to compare with.
     * @returns { Bool } True if both values are not equal, false otherwise.
     */

    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public operator func !=(other: PasteDataValueType): Bool {
        !(this == other)
    }
}

func getPasteboardErrorMessage(code: Int32): String {
    if (code == ERR_CODE_PERMISSION_DENIED) {
        return "Permission verification failed. The application does not have the permission required to call the API."
    }
    if (code == ERR_CODE_PARAMETER_ERROR) {
        return "Parameter error. Parameter verification failed."
    }
    if (code == ERR_CODE_INDEX_OUT_OF_RANGE) {
        return "The index is out of range."
    }
    if (code == ERR_CODE_TIMEOUT) {
        return "Excessive processing time for internal data."
    }
    if (code == ERR_CODE_OPERATION_IN_PROGRESS) {
        return "Another copy or paste operation is in progress."
    }
    if (code == ERR_CODE_REPLICATION_PROHIBITED) {
        return "Replication is prohibited."
    }
    "Pasteboard operation failed."
}

func checkPasteboardCodeOrThrow(code: Int32): Unit {
    if (code != SUCCESS_CODE) {
        throw BusinessException(code, getPasteboardErrorMessage(code))
    }
}

func takeCString(ret: RetDataCString): String {
    if (ret.code != SUCCESS_CODE) {
        unsafe { FfiOHOSFreeCString(ret.data) }
        return String.empty
    }
    if (ret.data.isNull()) {
        return String.empty
    }
    let result = ret.data.toString()
    unsafe { FfiOHOSFreeCString(ret.data) }
    result
}

func takeCArrString(ret: RetDataCArrString): Array<String> {
    var data = ret.data
    if (ret.code != SUCCESS_CODE) {
        unsafe { FfiOHOSFreeCArrString(inout data) }
        return []
    }
    let result = copyCArrString(data)
    unsafe { FfiOHOSFreeCArrString(inout data) }
    result
}

func copyCArrString(value: CArrString): Array<String> {
    unsafe {
        cArr2cjArr<CString, String>(value.size, value.head) {
            item => item.toString()
        }
    }
}

func toCArrString(values: Array<String>): CArrString {
    if (values.isEmpty()) {
        return CArrString(CPointer<CString>(), 0)
    }
    unsafe {
        let head = cjArr2CArr<String, CString>(values, { value => LibC.mallocCString(value) }) {
            value => LibC.free(value)
        }
        CArrString(head, values.size)
    }
}

func freeCArrString(value: CArrString): Unit {
    if (value.head.isNull()) {
        return
    }
    unsafe {
        for (i in 0..value.size) {
            LibC.free(value.head.read(i))
        }
        LibC.free(value.head)
    }
}

class ArrayRawDataResource <: Resource {
    private let handle: CPointerHandle<UInt8>
    private var closed: Bool = false

    init(buffer: Array<UInt8>) {
        handle = unsafe { acquireArrayRawData(buffer) }
    }

    public func isClosed(): Bool {
        closed
    }

    public func close(): Unit {
        if (!closed) {
            unsafe { releaseArrayRawData(handle) }
            closed = true
        }
    }

    prop pointer: CPointer<UInt8> {
        get() { handle.pointer }
    }
}

/**
 * Creates a **PasteData** object of the specified type.
 *
 * @param { String } mimeType - Type of PasteData. The value can be a predefined MIME type listed in Constants,
 *     including HTML, Want, plain text, URI, and PixelMap, or a custom type. The value of **mimeType** cannot
 *     exceed 1024 bytes.
 * @param { PasteDataValueType } value - Content of PasteData.
 * @returns { PasteData } **PasteData** object.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public func createData(mimeType: String, value: PasteDataValueType): PasteData {
    var ret = RetDataI64(SUCCESS_CODE, 0)
    unsafe {
        match (value) {
            case StringValue(text) =>
                try (cMimeType = LibC.mallocCString(mimeType).asResource(),
                    cValue = LibC.mallocCString(text).asResource()) {
                    ret = FfiOHOSCreateStringPasteData(cMimeType.value, cValue.value)
                }
            case PixelMapValue(pixelMap) =>
                try (cMimeType = LibC.mallocCString(mimeType).asResource()) {
                    ret = FfiOHOSCreatePixelMapPasteData(cMimeType.value, pixelMap.getID())
                }
            case ArrayBufferValue(buffer) =>
                try (arrayPtr = ArrayRawDataResource(buffer),
                    cMimeType = LibC.mallocCString(mimeType).asResource()) {
                    ret = FfiOHOSCreateArrayBufPasteData(cMimeType.value, arrayPtr.pointer, buffer.size)
                }
            case _ => throw BusinessException(ERR_CODE_PARAMETER_ERROR, "Parameter error. Parameter verification failed.")
        }
    }
    PasteData(ret.data)
}

/**
 * Creates a **PasteData** object that contains multiple types of data.
 *
 * @param { HashMap<String, PasteDataValueType> } data - The key of **HashMap** can be the MIME type corresponding to the
 *     PasteData, including HTML, Want, plain text, URI, and PixelMap defined in Constants. Alternatively, the key
 *     could be a custom type, whose parameter, the length of **mimeType**, cannot exceed 1024 bytes. The value of
 *     **HashMap** is the data corresponding to the type specified in the key. The first type specified by the
 *     key-value in **HashMap** is used as the default type of the first **PasteDataRecord** in the **PasteData**
 *     object. Data of non-default types can be read only by using the getData API of SystemPasteboard.
 * @returns { PasteData } **PasteData** object.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public func createData(data: HashMap<String, PasteDataValueType>): PasteData {
    var entries = CArrPasteDataEntry(data)
    let ret = unsafe { FfiOHOSCreateMultiTypePasteData(inout entries) }
    entries.free()
    PasteData(ret.data)
}

/**
 * Creates a **PasteDataRecord** object of the specified type.
 *
 * @param { String } mimeType - The type of custom data. The value can be a predefined MIME type listed in Constants,
 *     including HTML, Want, plain text, URI, and PixelMap, or a custom type. The value of **mimeType** cannot
 *     exceed 1024 bytes.
 * @param { PasteDataValueType } value - Data content of the specified type.
 * @returns { PasteDataRecord } A new paste data record of a specified type.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public func createRecord(mimeType: String, value: PasteDataValueType): PasteDataRecord {
    var cRecord = CPasteDataRecord()
    var ret = RetDataI64(SUCCESS_CODE, 0)
    unsafe {
        match (value) {
            case StringValue(text) =>
                try (cMimeType = LibC.mallocCString(mimeType).asResource(),
                    cValue = LibC.mallocCString(text).asResource()) {
                    ret = FfiOHOSCreateStringPasteDataRecord(cMimeType.value, cValue.value, inout cRecord)
                }
            case PixelMapValue(pixelMap) =>
                try (cMimeType = LibC.mallocCString(mimeType).asResource()) {
                    ret = FfiOHOSCreatePixelMapPasteDataRecord(cMimeType.value, pixelMap.getID(), inout cRecord)
                }
            case ArrayBufferValue(buffer) =>
                try (arrayPtr = ArrayRawDataResource(buffer),
                    cMimeType = LibC.mallocCString(mimeType).asResource()) {
                    ret = FfiOHOSCreateArrayBufPasteDataRecord(
                        cMimeType.value, arrayPtr.pointer, buffer.size, inout cRecord)
                }
            case _ => throw BusinessException(ERR_CODE_PARAMETER_ERROR, "Parameter error. Parameter verification failed.")
        }
    }
    let record = PasteDataRecord(ret.data, cRecord)
    unsafe { FfiOHOSFreePasteDataRecord(inout cRecord) }
    record
}

/**
 * Obtains **SystemPasteboard** object.
 *
 * @returns { SystemPasteboard } **SystemPasteboard** object.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public func getSystemPasteboard(): SystemPasteboard {
    let ret = unsafe { FfiOHOSGetSystemPasteboardV2() }
    SystemPasteboard(ret.data)
}

/**
 * Enumerates the pasteable ranges of PasteData.
 */
@Derive[ToString, Equatable]
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public enum ShareOption {
    /**
     * Only intra-application pasting is allowed.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    Inapp
    |
    /**
     * Paste is allowed in any application.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    Localdevice
    | ...
}

func shareOptionToValue(option: ShareOption): Int32 {
    match (option) {
        case Inapp => SHARE_OPTION_VALUE_INAPP
        case Localdevice => SHARE_OPTION_VALUE_LOCAL_DEVICE
        case _ => throw BusinessException(ERR_CODE_PARAMETER_ERROR, "Parameter error. Parameter verification failed.")
    }
}

func shareOptionFromValue(value: Int32): ShareOption {
    if (value == SHARE_OPTION_VALUE_INAPP) {
        return Inapp
    }
    if (value == SHARE_OPTION_VALUE_LOCAL_DEVICE) {
        return Localdevice
    }
    throw BusinessException(ERR_CODE_PARAMETER_ERROR, "Parameter error. Parameter verification failed.")
}


/**
 * Defines the properties of PasteData in the pasteboard, including the timestamp, data types, and pasteable range.
 * The defined properties can be applied to the pasteboard only with the setProperty method.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public class PasteDataProperty {
    private let pasteDataPropertyImpl: PasteDataPropertyImpl = PasteDataPropertyImpl()

    /**
     * Data types of all records in PasteData.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public prop mimeTypes: Array<String> {
        get() { pasteDataPropertyImpl.mimeTypes }
    }

    /**
     * Custom tag. This parameter is left empty by default.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop tag: String {
        get() { pasteDataPropertyImpl.tag }
        set(value) { pasteDataPropertyImpl.tag = value }
    }

    /**
     * Timestamp when data is written to the pasteboard (unit: nanoseconds since the device is powered on).
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public prop timestamp: Int64 {
        get() { pasteDataPropertyImpl.timestamp }
    }

    /**
     * Whether the pasteboard content is for local access only. The default value is **false**. The value will be
     * overwritten by the value of the **shareOption** attribute. You are advised to use the ShareOption attribute
     * instead.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop localOnly: Bool {
        get() { pasteDataPropertyImpl.localOnly }
        set(value) { pasteDataPropertyImpl.localOnly = value }
    }

    /**
     * Pasteable ranges of PasteData. The default value is **Localdevice**.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop shareOption: ShareOption {
        get() { pasteDataPropertyImpl.shareOption }
        set(value) { pasteDataPropertyImpl.shareOption = value }
    }

    /**
     * A constructor used to create a PasteDataProperty.
     *
     * @param { Array<String> } mimeTypes - Data types of all records in PasteData.
     * @param { String } tag - Custom tag. This parameter is left empty by default.
     * @param { Int64 } timestamp - Timestamp when data is written to the pasteboard (unit: nanoseconds since the
     *     device is powered on).
     * @param { Bool } localOnly - Whether the pasteboard content is for local access only. The default value is
     *     **false**. The value will be overwritten by the value of the **shareOption** attribute. You are advised
     *     to use the ShareOption attribute instead.
     * @param { ShareOption } shareOption - Pasteable ranges of PasteData. The default value is **Localdevice**.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public init(
        mimeTypes: Array<String>,
        tag: String,
        timestamp: Int64,
        localOnly: Bool,
        shareOption: ShareOption
    ) {
        pasteDataPropertyImpl.mimeTypes = mimeTypes
        pasteDataPropertyImpl.tag = tag
        pasteDataPropertyImpl.timestamp = timestamp
        pasteDataPropertyImpl.localOnly = localOnly
        pasteDataPropertyImpl.shareOption = shareOption
    }
}

class PasteDataPropertyImpl {
    var mimeTypes: Array<String> = []
    var tag: String = ""
    var timestamp: Int64 = 0
    var localOnly: Bool = false
    var shareOption: ShareOption = Localdevice
}

/**
 * Provides **PasteDataRecord** APIs. A **PasteDataRecord** is an abstract definition of the content in the
 * pasteboard. The pasteboard content consists of one or more plain text, HTML, URI, or Want records.
 * After creating a PasteDataRecord, it is not supported to modify the value of the default data type of the
 * PasteDataRecord. The correct value for the default data type should be specified when creating the PasteDataRecord.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public class PasteDataRecord {
    private let pasteDataRecordImpl: PasteDataRecordImpl

    internal init(id: Int64, record: CPasteDataRecord) {
        pasteDataRecordImpl = PasteDataRecordImpl(id, record)
    }

    func getID(): Int64 {
        pasteDataRecordImpl.getID()
    }

    /**
     * HTML content, must conform to standard HTML format. Modifications to this attribute are ineffective.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop htmlText: String {
        get() { pasteDataRecordImpl.htmlText }
        set(_) {}
    }

    /**
     * Default type of PasteDataRecord. Modifications to this attribute are ineffective.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop mimeType: String {
        get() { pasteDataRecordImpl.mimeType }
        set(_) {}
    }

    /**
     * Plain text. Modifications to this attribute are ineffective.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop plainText: String {
        get() { pasteDataRecordImpl.plainText }
        set(_) {}
    }

    /**
     * URI content, must conform to standard URI format. Modifications to this attribute are ineffective.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop uri: String {
        get() { pasteDataRecordImpl.uri }
        set(_) {}
    }

    /**
     * PixelMap content. Modifications to this attribute are ineffective.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public mut prop pixelMap: PixelMap {
        get() { pasteDataRecordImpl.pixelMap }
        set(_) {}
    }
}

class PasteDataRecordImpl <: RemoteDataLite {
    let htmlText: String
    let mimeType: String
    let plainText: String
    let uri: String
    let pixelMap: PixelMap

    init(id: Int64, record: CPasteDataRecord) {
        super(id)
        htmlText = record.htmlText.toString()
        mimeType = record.mimeType.toString()
        plainText = record.plainText.toString()
        uri = record.uri.toString()
        pixelMap = PixelMap(record.pixelMap)
    }

    ~init() {
        releaseFFIData(myDataId)
    }
}

/**
 * Implements a **PasteData** object. PasteData contains one or more data records (PasteDataRecord) and property
 * description objects (PasteDataProperty). Before calling any API in **PasteData**, you must use **createData()**
 * or **getData()** to create a **PasteData** object.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public class PasteData {
    private let pasteDataImpl: PasteDataImpl

    internal init(id: Int64) {
        pasteDataImpl = PasteDataImpl(id)
    }

    func getID(): Int64 {
        pasteDataImpl.getID()
    }

    /**
     * Adds a data record to the PasteData, and adds its type to **mimeTypes** in PasteDataProperty.
     * The parameters cannot be empty. Otherwise, the operation fails.
     *
     * @param { PasteDataRecord } record - Record to add.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func addRecord(record: PasteDataRecord): Unit {
        unsafe { FfiOHOSPasteDataAddRecord(getID(), record.getID()) }
    }

    /**
     * Adds a data record to the PasteData, and adds its type to **mimeTypes** in PasteDataProperty.
     * The parameters cannot be empty. Otherwise, the operation fails.
     *
     * @param { String } mimeType - MIME type of PasteData. The length cannot exceed 1024 bytes.
     * @param { PasteDataValueType } value - Data content.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func addRecord(mimeType: String, value: PasteDataValueType): Unit {
        unsafe {
            match (value) {
                case StringValue(text) =>
                    try (cMimeType = LibC.mallocCString(mimeType).asResource(),
                        cValue = LibC.mallocCString(text).asResource()) {
                        FfiOHOSPasteDataAddMimeTypeRecord(getID(), cMimeType.value, cValue.value)
                    }
                case PixelMapValue(pixelMap) =>
                    try (cMimeType = LibC.mallocCString(mimeType).asResource()) {
                        FfiOHOSPasteDataAddPixelMapRecord(getID(), cMimeType.value, pixelMap.getID())
                    }
                case ArrayBufferValue(buffer) =>
                    try (arrayPtr = ArrayRawDataResource(buffer),
                        cMimeType = LibC.mallocCString(mimeType).asResource()) {
                        FfiOHOSPasteDataAddArrayRecord(
                            getID(), cMimeType.value, arrayPtr.pointer, buffer.size)
                    }
                case _ => throw BusinessException(ERR_CODE_PARAMETER_ERROR, "Parameter error. Parameter verification failed.")
            }
        }
    }

    /**
     * Obtains types of PasteDataProperty of the PasteData.
     *
     * @returns { Array<String> } Data types of the PasteData.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getMimeTypes(): Array<String> {
        takeCArrString(unsafe { FfiOHOSPasteDataGetMimeTypes(getID()) })
    }

    /**
     * Obtains the HTML content of the primary record.
     *
     * @returns { String } HTML content.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getPrimaryHtml(): String {
        takeCString(unsafe { FfiOHOSPasteDataGetPrimaryHtml(getID()) })
    }

    /**
     * Obtains the data type of the primary record in the pasteboard.
     *
     * @returns { String } Data type of the primary record.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getPrimaryMimeType(): String {
        takeCString(unsafe { FfiOHOSPasteDataGetPrimaryMimeType(getID()) })
    }

    /**
     * Obtains the plain text of the primary record.
     *
     * @returns { String } Plain text.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getPrimaryText(): String {
        takeCString(unsafe { FfiOHOSPasteDataGetPrimaryText(getID()) })
    }

    /**
     * Obtains the URI of the primary record.
     *
     * @returns { String } URI content.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getPrimaryUri(): String {
        takeCString(unsafe { FfiOHOSPasteDataGetPrimaryUri(getID()) })
    }

    /**
     * Obtains the PixelMap of the primary record.
     *
     * @returns { PixelMap } PixelMap.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getPrimaryPixelMap(): PixelMap {
        let ret = unsafe { FfiOHOSPasteDataGetPrimaryPixelMap(getID()) }
        PixelMap(ret.data)
    }

    /**
     * Obtains the property of the PasteData.
     *
     * @returns { PasteDataProperty } Property of the PasteData.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getProperty(): PasteDataProperty {
        var cProperty = CPasteDataProperty()
        let code = unsafe { FfiOHOSPasteDataGetProperty(getID(), inout cProperty) }
        if (code != SUCCESS_CODE) {
            unsafe { FfiOHOSFreePasteDataProperty(inout cProperty) }
            return PasteDataProperty([], "", 0, false, Localdevice)
        }
        let property = PasteDataProperty(
            copyCArrString(cProperty.mimeTypes),
            cProperty.tag.toString(),
            cProperty.timestamp,
            cProperty.localOnly,
            shareOptionFromValue(cProperty.shareOption)
        )
        unsafe { FfiOHOSFreePasteDataProperty(inout cProperty) }
        property
    }

    /**
     * Sets a PasteDataProperty object.
     *
     * @param { PasteDataProperty } pasteDataProperty - Property of the PasteData.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func setProperty(pasteDataProperty: PasteDataProperty): Unit {
        let mimeTypes = toCArrString(pasteDataProperty.mimeTypes)
        unsafe {
            try (cTag = LibC.mallocCString(pasteDataProperty.tag).asResource()) {
                FfiOHOSPasteDataSetProperty(
                    getID(), mimeTypes, cTag.value, pasteDataProperty.timestamp,
                    pasteDataProperty.localOnly, shareOptionToValue(pasteDataProperty.shareOption))
            }
        }
        freeCArrString(mimeTypes)
    }

    /**
     * Obtains the record with a specific index in PasteData.
     *
     * @param { Int32 } index - Index of the target record.
     * @returns { PasteDataRecord } Record with the specified index.
     * @throws { BusinessException } 12900001 - The index is out of range.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func getRecord(index: Int32): PasteDataRecord {
        var cRecord = CPasteDataRecord()
        let ret = unsafe { FfiOHOSPasteDataGetRecordV2(getID(), index, inout cRecord) }
        if (ret.code != SUCCESS_CODE || ret.data <= 0) {
            unsafe { FfiOHOSFreePasteDataRecord(inout cRecord) }
            throw BusinessException(ERR_CODE_INDEX_OUT_OF_RANGE, getPasteboardErrorMessage(ERR_CODE_INDEX_OUT_OF_RANGE))
        }
        let record = PasteDataRecord(ret.data, cRecord)
        unsafe { FfiOHOSFreePasteDataRecord(inout cRecord) }
        record
    }

    /**
     * Obtains the number of records in a PasteData object.
     *
     * @returns { UIntNative } Number of records.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getRecordCount(): UIntNative {
        let ret = unsafe { FfiOHOSPasteDataGetRecordCount(getID()) }
        if (ret.code != SUCCESS_CODE) {
            return 0
        }
        ret.data
    }

    /**
     * Obtains the custom tag from the PasteData. If no custom tag is set, an empty string is returned.
     *
     * @returns { String } Custom tag. If no custom tag is set, an empty string is returned.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func getTag(): String {
        takeCString(unsafe { FfiOHOSPasteDataGetTag(getID()) })
    }

    /**
     * Checks whether the PasteData contains data of the specified MIME type.
     *
     * @param { String } mimeType - Type of the data to query. The value can be a predefined type listed in
     *     Constants, including HTML, Want, plain text, URI, and PixelMap, or a custom type.
     * @returns { Bool } Returns **true** if the specified data type exists; returns **false** otherwise.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func hasType(mimeType: String): Bool {
        let ret = unsafe {
            let cMimeType = LibC.mallocCString(mimeType)
            let result = FfiOHOSPasteDataHasType(getID(), cMimeType)
            LibC.free(cMimeType)
            result
        }
        if (ret.code != SUCCESS_CODE) {
            return false
        }
        ret.data
    }

    /**
     * Removes the record with a specific index in PasteData.
     *
     * @param { Int32 } index - Specified index.
     * @throws { BusinessException } 12900001 - The index is out of range.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func removeRecord(index: Int32): Unit {
        checkPasteboardCodeOrThrow(unsafe { FfiOHOSPasteDataRemoveRecord(getID(), index) })
    }

    /**
     * Replaces the record with a specific index in PasteData.
     *
     * @param { Int32 } index - Specified index.
     * @param { PasteDataRecord } record - New record.
     * @throws { BusinessException } 12900001 - The index is out of range.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func replaceRecord(index: Int32, record: PasteDataRecord): Unit {
        checkPasteboardCodeOrThrow(unsafe { FfiOHOSPasteDataReplaceRecord(getID(), record.getID(), index) })
    }
}

class PasteDataImpl <: RemoteDataLite {
    init(id: Int64) {
        super(id)
    }

    ~init() {
        releaseFFIData(myDataId)
    }
}

/**
 * Provides **SystemPasteboard** APIs.
 * Before calling any **SystemPasteboard** API, you must obtain a **SystemPasteboard** object using
 * getSystemPasteboard.
 */
@!APILevel[
    since: "26.1.0",
    syscap: "SystemCapability.MiscServices.Pasteboard"
]
public class SystemPasteboard {
    private let systemPasteboardImpl: SystemPasteboardImpl

    internal init(id: Int64) {
        systemPasteboardImpl = SystemPasteboardImpl(id)
    }

    func getID(): Int64 {
        systemPasteboardImpl.getID()
    }

    /**
     * Checks whether the data in the pasteboard is from another device.
     *
     * @returns { Bool } Returns **true** if the data in the pasteboard is from another device;
     *     returns **false** otherwise.
     * @throws { BusinessException } 12900005 - Excessive processing time for internal data.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func isRemoteData(): Bool {
        let ret = unsafe { FfiOHOSSystemPasteboardIsRemoteDataV2(getID()) }
        checkPasteboardCodeOrThrow(ret.code)
        ret.data
    }

    /**
     * Obtains the name of the application that provides data.
     *
     * @returns { String } Application name.
     * @throws { BusinessException } 12900005 - Excessive processing time for internal data.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func getDataSource(): String {
        let ret = unsafe { FfiOHOSSystemPasteboardGetDataSourceV2(getID()) }
        checkPasteboardCodeOrThrow(ret.code)
        if (ret.data.isNull()) {
            return String.empty
        }
        let result = ret.data.toString()
        unsafe { FfiOHOSFreeCString(ret.data) }
        result
    }

    /**
     * Checks whether the pasteboard contains data of the specified type.
     *
     * @param { String } mimeType - Data type.
     * @returns { Bool } Returns **true** if the pasteboard contains data of the specified type; returns **false**
     *     otherwise.
     * @throws { BusinessException } 12900005 - Excessive processing time for internal data.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func hasDataType(mimeType: String): Bool {
        let ret = unsafe {
            let cMimeType = LibC.mallocCString(mimeType)
            let result = FfiOHOSSystemPasteboardHasDataTypeV2(getID(), cMimeType)
            LibC.free(cMimeType)
            result
        }
        checkPasteboardCodeOrThrow(ret.code)
        ret.data
    }

    /**
     * Clears the system pasteboard. This API uses an asynchronous callback to return the result.
     *
     * @param { AsyncCallback<Unit> } callback - Callback used to return the result.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard"
    ]
    public func clearData(callback: AsyncCallback<Unit>): Unit {
        spawn {
            unsafe { FfiOHOSSystemPasteboardClearData(getID()) }
            callback(None, Some(()))
        }
    }

    /**
     * Obtains a **PasteData** object from the pasteboard. This API uses an asynchronous callback to return the result..
     *
     * While most applications must request permissions to access the pasteboard, those using PasteButton can
     * access the pasteboard content without permission requests.
     *
     * @param { AsyncCallback<PasteData> } callback - Callback used to return the result.
     * @throws { BusinessException } 27787277 - Another copy or paste operation is in progress.
     * @throws { BusinessException } 201 - Permission verification failed. The application does not have the
     *     permission required to call the API.
     */
    @!APILevel[
        since: "26.1.0",
        permission: "ohos.permission.READ_PASTEBOARD",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func getData(callback: AsyncCallback<PasteData>): Unit {
        spawn {
            let ret = unsafe { FfiOHOSSystemPasteboardGetDataV2(getID()) }
            if (ret.code != SUCCESS_CODE) {
                callback(Some(BusinessException(ret.code, getPasteboardErrorMessage(ret.code))), None)
            } else if (ret.data <= 0) {
                callback(Some(BusinessException(ERR_CODE_INVALID_OBJECT, "Failed to create the native pasteboard object.")), None)
            } else {
                callback(None, Some(PasteData(ret.data)))
            }
        }
    }

    /**
     * Checks whether the system pasteboard contains data. This API uses an asynchronous callback to return the result.
     *
     * @param { AsyncCallback<Bool> } callback - Callback used to return the result. Returns **true** if the system
     *     pasteboard contains data; returns **false** otherwise.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func hasData(callback: AsyncCallback<Bool>): Unit {
        spawn {
            let ret = unsafe { FfiOHOSSystemPasteboardHasData(getID()) }
            if (ret.code != SUCCESS_CODE) {
                callback(Some(BusinessException(ret.code, getPasteboardErrorMessage(ret.code))), None)
            } else {
                callback(None, Some(ret.data))
            }
        }
    }

    /**
     * Writes a **PasteData** object to the pasteboard. This API uses an asynchronous callback to return the result.
     *
     * @param { PasteData } data - **PasteData** object.
     * @param { AsyncCallback<Unit> } callback - Callback used to return the result.
     * @throws { BusinessException } 27787277 - Another copy or paste operation is in progress.
     * @throws { BusinessException } 27787278 - Replication is prohibited.
     */
    @!APILevel[
        since: "26.1.0",
        syscap: "SystemCapability.MiscServices.Pasteboard",
        throwexception: true
    ]
    public func setData(data: PasteData, callback: AsyncCallback<Unit>): Unit {
        spawn {
            let code = unsafe { FfiOHOSSystemPasteboardSetDataV2(getID(), data.getID()) }
            if (code != SUCCESS_CODE) {
                callback(Some(BusinessException(code, getPasteboardErrorMessage(code))), None)
            } else {
                callback(None, Some(()))
            }
        }
    }
}

class SystemPasteboardImpl <: RemoteDataLite {
    init(id: Int64) {
        super(id)
    }

    ~init() {
        releaseFFIData(myDataId)
    }
}
