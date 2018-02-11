
4 main blocks are stored in VTF

normals{}

    Stores the relative vector for shifting the vertex. Always normalized.

distances{}

	Stores the distance of moving the vertex away from it's base position. Scalar.

offsets{}

	Stores offset for each vertex.

offset_normals{} 

	Stores normal vector in position of each vertex. This is not used by VBSP. Seems like it's only used for exporting the map to Maya.

Only first two are modified by Hammer. They also map directly to how displacements are stored in bsp file. I'm not sure about how normal directions are computed when map is loaded.

When converting this data from splines i will do the following:

1. Find out an apex of the surface and curves of each of 4 edges
2. Solve a least squares approximation for the plane. That would be our displacement plane
3. Compute normals and positions for each subdivision point
4. Reproject those positions back onto the plane
5. Store positions as ``offsets`` and store normals as both ``normals`` and ``offset_normals``
6. Add planes to the brush that form an AABB around the displacement (maybe there is info i can copy form Q3 map)

