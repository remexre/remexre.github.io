+++
title = "Notebook: Vulkan"

[taxonomies]
tags = ["vulkan"]
+++

nova
====

goal:

-	type-safe
-	sync-safe
-	raii

Example
-------

```dot
digraph {
	graph[rankdir=LR];

	updateParticleWorldPosns;
	clearParticleScreenPosns;
	drawGeometry;
	updateParticles;
	shade;

	drawGeometry -> updateParticles [taillabel=LATE_FRAGMENT_TESTS, headlabel=COMPUTE_SHADER];
	updateParticleWorldPosns -> updateParticles [taillabel=TRANSFER, headlabel=COMPUTE_SHADER];
	clearParticleScreenPosns -> updateParticles [taillabel=TRANSFER, headlabel=COMPUTE_SHADER];
	drawGeometry -> shade [taillabel=COLOR_ATTACHMENT_OUTPUT, headlabel=FRAGMENT_SHADER];
	updateParticles -> shade [taillabel=COMPUTE_SHADER, headlabel=FRAGMENT_SHADER];
}
```

API
---

`Device : *`

-	`new_device : Target t => t -o Device`

`Cmd : * -> *`

-	`run : Device -> Cmd a -o a`

`CmdBufUsage : *`

-	`OneTimeSubmit : CmdBufUsage`
-	`Reusable : CmdBufUsage`

`CmdBuf : CmdBufTypeState -> *`

-	`submit : CmdBuf (Executable t) -o CmdBuf (Pending t)`
-	`waitComplete : CmdBuf (Pending Reusable) -o CmdBuf (Executable Reusable)`
-	`waitCompleteOne : CmdBuf (Pending OneTimeSubmit) -o CmdBuf Invalid`

`Image : *`

-	`create : Device -> Image`
-	`destroy : Image -o ()`
