const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const PipelineLayout = @import("pipeline.zig").PipelineLayout;

const _misc = @import("misc.zig");
const WGPUFlags = _misc.WGPUFlags;
const StringView = _misc.StringView;

pub const ShaderStage = WGPUFlags;
pub const ShaderStages = struct {
    pub const none     = @as(ShaderStage, 0x00000000);
    pub const vertex   = @as(ShaderStage, 0x00000001);
    pub const fragment = @as(ShaderStage, 0x00000002);
    pub const compute  = @as(ShaderStage, 0x00000004);
};

pub const CompilationHint = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    entry_point: [*:0]const u8,
    layout: *PipelineLayout,
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: *const ChainedStruct,
    label: ?[*:0]const u8 = null,
    hint_count: usize = 0,
    hints: [*]const CompilationHint = (&[_]CompilationHint{}).ptr,
};

// This is specific to wgpu-native (from wgpu.h), and unfortunately it is *NOT* the same thing as ShaderSourceSPIRV
pub const ShaderModuleDescriptorSpirV = extern struct {
    label: StringView,
    source_size: u32,
    source: [*]const u32,
};

pub const ShaderModuleSPIRVDescriptor = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_module_spirv_descriptor,
    },
    code_size: u32,
    code: [*]const u32,
};
pub const ShaderModuleSPIRVMergedDescriptor = struct {
    label: ?[*:0]const u8 = null,
    hint_count: usize = 0,
    hints: [*]const CompilationHint = (&[_]CompilationHint{}).ptr,
    code_size: u32,
    code: [*]const u32,
};
pub inline fn shaderModuleSPIRVDescriptor(
    descriptor: ShaderModuleSPIRVMergedDescriptor
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderModuleSPIRVDescriptor {
            .code_size = descriptor.code_size,
            .code = descriptor.code,
        }),
        .label = descriptor.label,
        .hint_count = descriptor.hint_count,
        .hints = descriptor.hints,
    };
}

pub const ShaderModuleWGSLDescriptor = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_module_wgsl_descriptor,
    },
    code: [*:0]const u8,
};
pub const ShaderModuleWGSLMergedDescriptor = struct {
    label: ?[*:0]const u8 = null,
    hint_count: usize = 0,
    hints: [*]const CompilationHint = (&[_]CompilationHint{}).ptr,
    code: [*:0]const u8,
};
pub inline fn shaderModuleWGSLDescriptor(
    descriptor: ShaderModuleWGSLMergedDescriptor,
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderModuleWGSLDescriptor {
            .code = descriptor.code,
        }),
        .label = descriptor.label,
        .hint_count = descriptor.hint_count,
        .hints = descriptor.hints,
    };
}

pub const ShaderDefine = extern struct {
    name: StringView,
    value: StringView,
};
pub const ShaderModuleGLSLDescriptor = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_module_glsl_descriptor,
    },
    stage: ShaderStage,
    code: StringView,
    define_count: u32 = 0,
    defines: ?[*]ShaderDefine = null,
};
pub const ShaderModuleGLSLMergedDescriptor = struct {
    label: ?[*:0]const u8 = null,
    hint_count: usize = 0,
    hints: [*]const CompilationHint = (&[_]CompilationHint{}).ptr,
    stage: ShaderStage,
    code: [*:0]const u8,
    define_count: u32 = 0,
    defines: ?[*]ShaderDefine = null,
};
pub inline fn shaderModuleGLSLDescriptor(
    descriptor: ShaderModuleGLSLMergedDescriptor,
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderModuleGLSLDescriptor {
            .stage = descriptor.stage,
            .code = descriptor.code,
            .define_count = descriptor.define_count,
            .defines = descriptor.defines,
        }),
        .label = descriptor.label,
        .hint_count = descriptor.hint_count,
        .hints = descriptor.hints,
    };
}

pub const CompilationInfoRequestStatus = enum(u32) {
    success     = 0x00000000,
    @"error"    = 0x00000001,
    device_lost = 0x00000002,
    unknown     = 0x00000003,
};

pub const CompilationMessageType = enum(u32) {
    @"error" = 0x00000000,
    warning  = 0x00000001,
    info     = 0x00000002,
};

pub const CompilationMessage = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message: ?[*:0]const u8 = null,
    @"type": CompilationMessageType,
    line_num: u64,
    line_pos: u64,
    offset: u64,
    length: u64,
    utf16_line_pos: u64,
    utf16_offset: u64,
    utf16_length: u64,
};

pub const CompilationInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message_count: usize,
    messages: [*]const CompilationMessage,
};

pub const ShaderModuleGetCompilationInfoCallback = *const fn(status: CompilationInfoRequestStatus, compilation_info: ?*const CompilationInfo, userdata: ?*anyopaque) callconv(.C) void;

pub const ShaderModuleProcs = struct {
    pub const GetCompilationInfo = *const fn(*ShaderModule, ShaderModuleGetCompilationInfoCallback, ?*anyopaque) callconv(.C) void;
    pub const SetLabel = *const fn(*ShaderModule, ?[*:0]const u8) callconv(.C) void;
    pub const AddRef = *const fn(*ShaderModule) callconv(.C) void;
    pub const Release = *const fn(*ShaderModule) callconv(.C) void;
};

extern fn wgpuShaderModuleGetCompilationInfo(shader_module: *ShaderModule, callback: ShaderModuleGetCompilationInfoCallback, userdata: ?*anyopaque) void;
extern fn wgpuShaderModuleSetLabel(shader_module: *ShaderModule, label: ?[*:0]const u8) void;
extern fn wgpuShaderModuleAddRef(shader_module: *ShaderModule) void;
extern fn wgpuShaderModuleRelease(shader_module: *ShaderModule) void;

pub const ShaderModule = opaque {
    pub inline fn getCompilationInfo(self: *ShaderModule, callback: ShaderModuleGetCompilationInfoCallback, userdata: ?*anyopaque) void {
        wgpuShaderModuleGetCompilationInfo(self, callback, userdata);
    }
    pub inline fn setLabel(self: *ShaderModule, label: ?[*:0]const u8) void {
        wgpuShaderModuleSetLabel(self, label);
    }
    pub inline fn reference(self: *ShaderModule) void {
        wgpuShaderModuleAddRef(self);
    }
    pub inline fn addRef(self: *ShaderModule) void {
        wgpuShaderModuleAddRef(self);
    }
    pub inline fn release(self: *ShaderModule) void {
        wgpuShaderModuleRelease(self);
    }
};