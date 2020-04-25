function draw_network(tbJson, brain_area_level = 1, behavior_level = 1) {
	var myChart = echarts.init(document.getElementById('network_chart'));
	myChart.showLoading();
//    console.log(tbJson);

	myChart.hideLoading();

	var behavior_dict = {};
	var brain_area_dict = {};

	var generate_dict = {};

	if (behavior_level == 1) {
		generate_dict["behavior_value"] = (function(tb_row) {
			return tb_row.condition;
		});
	} else {
		generate_dict["behavior_value"] = (function(tb_row) {
			return tb_row.behavior;
		});
	}

	generate_dict["brain_area_value"] = (function(tb_row) {
		return [tb_row.brain_code, tb_row.main];
	});

	
	for (i=0; i<tbJson.length; i++) {
		brain_area_dict[tbJson[i].brain_code] = generate_dict.brain_area_value(tbJson[i]);
		behavior_dict[tbJson[i].condition] = generate_dict.behavior_value(tbJson[i]);
	}

	var query_dict;
	if (brain_area_level == 1) {
		query_dict = (function(x) {
			return x;
		})
	} else {
		query_dict = (function(x) {
			var parent = x.split(".")[0];
			if (brain_area_dict[parent]) {
				return parent;
			} else {
				return x;
			}
		})
	}

	var links = {}, data = {};
	for (i=0; i<tbJson.length; i++) {
		var source = behavior_dict[tbJson[i].condition],
			target = brain_area_dict[query_dict(tbJson[i].brain_code)],
			link_key = source + target[0];

		if (links[link_key]) {
			links[link_key].lineStyle.width++;
		} else {
			links[link_key] = {
				source : source,
				target : target[0],
				lineStyle : {
					width : 1
				}
			}
		}

		if (data[source]) {
			data[source].value++;
		} else {
			data[source] = {
				id : source,
				name : source,
				value : 1,
				category : 0,
			}
		}

		if (data[target[0]]) {
			data[target[0]].value++;
		} else {
			data[target[0]] = {
				id : target[0],
				name : target[1],
				value : 1,
				category : 1,
			}
		}
	}

	var graph = {links : [], nodes: []};
	for (i in links) {
		graph.links.push(links[i]);
	}
	for (i in data) {
		graph.nodes.push(data[i]);
	}

	var categories = [
		{
			name: "Condition",
		},
		{
			name: "Brain Area"
		}
	];
	graph.nodes.forEach(function (node) {
		node.itemStyle = null;
		node.symbolSize = node.value * 5;
		node.label = {
			normal: {
				show: true
				//node.symbolSize > 0
			}
		};
		// node.category = node.attributes.modularity_class;
	});
	option = {
		title: {
			text: 'cFOS Brain Area - Treatment Mapping',
			subtext: '',
			top: 'top',
			left: 'left'
		},
		tooltip: {},
		legend: [{
			// selectedMode: 'single',
			data: categories.map(function (a) {
				return a.name;
			}),
			left: 'right'
		}],
		animationDuration: 1500,
		animationEasingUpdate: 'quinticInOut',
		series : [
			{
				name: '',
				type: 'graph',
				layout: 'circular',
				data: graph.nodes,
				links: graph.links,
				categories: categories,
				roam: true,
				focusNodeAdjacency: true,
				itemStyle: {
					normal: {
						borderColor: '#fff',
						borderWidth: 1,
						shadowBlur: 10,
						shadowColor: 'rgba(0, 0, 0, 0.3)'
					}
				},
				label: {
					position: 'right',
					formatter: '{b}'
				},
				lineStyle: {
					color: 'source',
					curveness: 0.3
				},
				emphasis: {
					lineStyle: {
						width: 10
					}
				}
			}
		]
	};

	myChart.setOption(option);
}
