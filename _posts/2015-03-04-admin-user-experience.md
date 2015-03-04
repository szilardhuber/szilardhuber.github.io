---
layout: post
title:  "Do admininstrative UIs have to be ugly?"
date:   2015-03-04 08:39:21
categories: ux ui design 
---

I come from the field of building consumer products. I was lucky enough to have a close look on how applications with great user experience like [join.me](https://join.me) and [Cubby](https://www.cubby.com) evolve. With such background it was a shock to me how complicated [ETL](http://en.wikipedia.org/wiki/Extract,_transform,_load) tools are. They look like no one cared about their design. 

|----------------------------------------------------------------------------------|
| ![ETL Tool 1](/assets/etl1.jpg)             |      ![ETL Tool 2](/assets/ETL2.png)      |
| ![ETL Tool 3](/assets/ETL3.png)             |      ![ETL Tool 4](/assets/ETL4.png)      |

I know these have a wide range of features combined into a single desktop application. Even so their primary focus is on the so called "power users". But for me these are not excuses for not caring about user experience. All these have buttons and toolbars and panes and scrollbars everywhere. For me it is scary even to look at them not to mention the possibility of maybe having to learn to use them.

Our goal with [VirtDB](https://www.virtdb.com) from the beginning was to ease the access to external data. We created a web UI with the focus on importing the external data to host systems. We beleive in the Unix philosophy: [Do one thing well](http://www.thedolectures.com/shop/do-one-thing-well)

![Original GUI](/assets/olduiemp.png)

You select the data source (oracle at the example), select and check the table, click on ```Add``` and voila. You are ready to use Oracle data in your host system. 

Also we started working together with a designer to improve the look and feel of our GUI. But a designer is ready when he is ready. While waiting for him we still want to keep enhancing our product and improve customer satisfaction. The current design is how GUIs look like if developers create them. :) Functional, working but not so pretty. Preparing for the Tableau Conference this week I could not resist any longer to tidy up a bit. Let's have a closer look on what could be better:

  - The Data providers panel header is unnecessary. 
  - The list of the providers is too compact. 
  - The filter dropdown toggle eats up to much space. It is not clear what happens when I click on that row.
  - The search box is too thin. The page controls take up space in that row.
  - Table count and paging information take up a whole row. So does selection information.
  - Add button is on the bottom of the list which can make it hard to find.
  - On the data view an unnecessary vertical scroll bar is present.
  - Tanspose button is ugly and also takes a whole row.
  - Meta data section is visible even when it does not show any information.

So one by one I fixed these issues and got the following results:

![New GUI](/assets/newuiemp.png)

On my monitor I get **7 rows** of data **instead of 4** in the data view which I think is cool.

  - I removed the data providers panel.
  - Added some padding to the providers in the list.
  - Replaced filter row to an icon. It now even displays if a filter is set or empty.
  - Search box is as wide as it can be. Page controls are up next to the filter icon.
  - Table count is where it should be. Paging information is displayed only if it is meaningful (not shown in the screenshot.)
  - Selection information is combined with the ```Add``` button as they have meaning only together.
  - Add button is more visible. (I still don't find it emphasized enough but I think the designer will come up with some cool solution for it.)
  - Unwanted scrollbar removed from the data view.
  - Transpose button is consistent with the rest of the page and does not need a whole row anymore.
  - Meta data section is visible only if it has relevant information. (So it is not visible in the screenshot.)

If you have any ideas on how to further improve our UX. Or you know how it could be easier to import data from external sources to PostgreSQL or Greenplum just drop a comment below!
